#!/usr/bin/perl

package ZHex::Event;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     obj_init 
     $VERS 
     EDT_CTXT_DEFAULT 
     EDT_CTXT_INSERT 
     EDT_CTXT_SEARCH);

BEGIN { require Exporter;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw();
}

# Functions: Start-Up/Initialization.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Global variable declarations.

sub init {

	my $self = shift;

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;
	$self->{'curs_ctxt_prev'} = 0;

	# Event callback subroutine references.

	$self->{'cb'} = {};
	$self->{'cb'}->{EDT_CTXT_DEFAULT} = {};
	$self->{'cb'}->{EDT_CTXT_INSERT}  = {};
	$self->{'cb'}->{EDT_CTXT_SEARCH}  = {};

	# Event signatures: map @evt array (returned by Win32::Console) to "event name".

	$self->{'evt_sig'} = {};
	$self->{'evt_sig'}->{EDT_CTXT_DEFAULT} = {};
	$self->{'evt_sig'}->{EDT_CTXT_INSERT}  = {};
	$self->{'evt_sig'}->{EDT_CTXT_SEARCH}  = {};

	return (1);
}

# ______________________________________________________________________________

# Functions: That used to live in EventLoop.pm.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   register_callback()		Register callback subroutine to handle event under certain context.
#   register_evt_sig()		Register event signature (unique values of evt array that identify different keystrokes).
#   gen_evt_array()		...
#   evt_map()			...
#   evt_dispatch()		...

sub register_callback {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to register_callback() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_ctxt'} || 
	    ! defined $arg->{'edt_ctxt'} || 
	             ($arg->{'edt_ctxt'} eq '')) 
		{ die "Call to register_callback() failed, value associated w/ key 'edt_ctxt' was undef/empty string"; }

	if (! exists  $arg->{'evt_nm'} || 
	    ! defined $arg->{'evt_nm'} || 
	             ($arg->{'evt_nm'} eq '')) 
		{ die "Call to register_callback() failed, value associated w/ key 'evt_nm' was undef/empty string"; }

	if (! exists  $arg->{'evt_cb'} || 
	    ! defined $arg->{'evt_cb'} || 
	      ! (ref ($arg->{'evt_cb'}) eq 'CODE')) 
		{ die "Call to register_callback() failed, value associated w/ key 'evt_cb' must be code reference"; }

	if (! exists  $arg->{'evt'} || 
	    ! defined $arg->{'evt'} || 
	      ! (ref ($arg->{'evt'}) eq 'ARRAY')) 
		{ die "Call to register_callback() failed, value associated w/ key 'evt' must be array reference"; }   # <--- Change back to die...

	# Store callback in callback hash: $self->{'cb'}.

	$self->{'cb'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} } = $arg->{'evt_cb'};

	foreach my $evt_sig (@{ $arg->{'evt'} }) {

		# Store event signature in [wherever it gets stored].

		$self->register_evt_sig 
		  ({ 'edt_ctxt' => $arg->{'edt_ctxt'}, 
		     'evt_nm'   => $arg->{'evt_nm'}, 
		     'evt'      => $evt_sig });
	}

	# $self->{'obj'}->{'debug'}->errmsg ("Registered callback for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'edt_ctxt'} . "'.\n");
	# warn ("Registered callback for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'edt_ctxt'} . "').");

	return (1);
}

sub register_evt_sig {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to register_evt_sig() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_ctxt'} || 
	    ! defined $arg->{'edt_ctxt'} || 
	             ($arg->{'edt_ctxt'} eq '')) 
		{ die "Call to register_evt_sig() failed, value associated w/ key 'edt_ctxt' must not be undef/empty"; }

	if (! exists  $arg->{'evt_nm'} || 
	    ! defined $arg->{'evt_nm'} || 
	             ($arg->{'evt_nm'} eq '')) 
		{ die "Call to register_evt_sig() failed, value associated w/ key 'evt_nm' must not be undef/empty"; }

	if (! exists  $arg->{'evt'} || 
	    ! defined $arg->{'evt'} || 
	             ($arg->{'evt'} eq '') || 
	      ! (ref ($arg->{'evt'}) eq 'ARRAY')) 
		{ die "Call to register_evt_sig() failed, value associated w/ key 'evt' must be array ref"; }

	# Register a set of callback matching criteria.

	if (! exists  $self->{'evt_sig'} ||
	    ! defined $self->{'evt_sig'} || 
	      ! (ref ($self->{'evt_sig'}) eq 'HASH')) {

		$self->{'evt_sig'} = {};
	}

	if (! exists  $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} } || 
	    ! defined $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} } || 
	      ! (ref ($self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }) eq 'HASH')) {

		$self->{'evt_sig'}->{ $arg->{'edt_ctxt'} } = {};
	}

	if (! (exists  $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }) || 
	    ! (defined $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }) || 
	       ! (ref ($self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }) eq 'ARRAY')) { 

		$self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} } = [];
	}

	push @{ $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} } }, 
	     $arg->{'evt'};

	# $self->{'obj'}->{'debug'}->errmsg ("Registered event signature for '" . $arg->{'evt_nm'} . "'.\n");
	# warn ("Registered event signature for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'edt_ctxt'} . "'.");

	# warn 
	#   ("evt0='" . $arg->{'evt'}->[0] . "', " . 
	#    "evt1='" . $arg->{'evt'}->[1] . "', " . 
	#    "evt2='" . $arg->{'evt'}->[2] . "', " . 
	#    "evt3='" . $arg->{'evt'}->[3] . "', " . 
	#    "evt4='" . $arg->{'evt'}->[4] . "', " . 
	#    "evt5='" . $arg->{'evt'}->[5] . "', " . 
	#    "evt6='" . $arg->{'evt'}->[6] . "'.");

	return (1);
}

sub gen_evt_array {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_evt_array() failed, argument must be hash reference"; }

	my $evt_array = [];

	if (exists  $arg->{'0'} && 
	    defined $arg->{'0'} && 
	         ! ($arg->{'0'} eq '')) 
		{ $evt_array->[0] = $arg->{'0'}; }
	   else { $evt_array->[0] = ''; }

	if (exists  $arg->{'1'} && 
	    defined $arg->{'1'} && 
	         ! ($arg->{'1'} eq '')) 
		{ $evt_array->[1] = $arg->{'1'}; }
	   else { $evt_array->[1] = ''; }

	if (exists  $arg->{'2'} && 
	    defined $arg->{'2'} && 
	         ! ($arg->{'2'} eq '')) 
		{ $evt_array->[2] = $arg->{'2'}; }
	   else { $evt_array->[2] = ''; }

	if (exists  $arg->{'3'} && 
	    defined $arg->{'3'} && 
	         ! ($arg->{'3'} eq '')) 
		{ $evt_array->[3] = $arg->{'3'}; }
	   else { $evt_array->[3] = ''; }

	if (exists  $arg->{'4'} && 
	    defined $arg->{'4'} && 
	         ! ($arg->{'4'} eq '')) 
		{ $evt_array->[4] = $arg->{'4'}; }
	   else { $evt_array->[4] = ''; }

	if (exists  $arg->{'5'} && 
	    defined $arg->{'5'} && 
	         ! ($arg->{'5'} eq '')) 
		{ $evt_array->[5] = $arg->{'5'}; }
	   else { $evt_array->[5] = ''; }

	if (exists  $arg->{'6'} && 
	    defined $arg->{'6'} && 
	         ! ($arg->{'6'} eq '')) 
		{ $evt_array->[6] = $arg->{'6'}; }
	   else { $evt_array->[6] = ''; }

	return ($evt_array);
}

sub evt_map {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to evt_map() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_ctxt'} || 
	    ! defined $arg->{'edt_ctxt'} || 
	             ($arg->{'edt_ctxt'} eq '')) 
		{ die "Call to evt_map() failed, value associated w/ key 'edt_ctxt' was undef or empty string"; }

	if (! exists  $arg->{'evt'} || 
	    ! defined $arg->{'evt'} || 
	             ($arg->{'evt'} eq '') || 
	      ! (ref ($arg->{'evt'}) eq 'ARRAY')) 
		{ die "Call to evt_map() failed, value associated w/ key 'evt' must be array ref"; }

	my $objCharMap = $self->{'obj'}->{'charmap'};
	my $objDebug   = $self->{'obj'}->{'debug'};

	# EVT Array Idx	Element Name		Values
	# _____________	____________		______
	# $evt->[0]	Event Type		1 == Keyboard Event
	# $evt->[1]	Key   Down		1 == Key Pressed
	# $evt->[2]	???			-
	# $evt->[3]	Virtual Keycode		-
	# $evt->[4]	Virtual Scancode	-
	# $evt->[5]	???			-
	# $evt->[6]	?Control Key Status?	-

	my $evt = $arg->{'evt'};

	# Eliminate non-interesting events.

	if (exists $evt->[0] && ($evt->[0] == 2) &&   # Event_Type: 2 (indicates mouse event).
	    exists $evt->[3] && 
	       ( (($evt->[3] ==  1) ||                # Button_State:        1 (indicates left  mouse button).
	          ($evt->[3] ==  2)) ||               # Button_State:        2 (indicates right mouse button).
	       ( (($evt->[3] ==  7864320) ||          # Button_State:  7864320 (indicates mouse wheel roll upward).
	          ($evt->[3] == -7864320)) &&         # Button_State: -7864320 (indicates mouse wheel roll downward).
	  (defined $evt->[5] && ($evt->[5] == 4)) ) )) {

		# Mouse button pressed, may be an event in this context, pass through...

		undef;
	}
	elsif (defined $evt->[0] && ($evt->[0] == 2) &&              # Event_Type:    2 (indicates 'mouse' event).
	       defined $evt->[1] && ($evt->[1] =~ /^\d\d?\d?$/) &&   # X Coordinate:  One to three digits.
	       defined $evt->[2] && ($evt->[2] =~ /^\d\d?\d?$/) &&   # Y Coordinate:  One to three digits.
	       defined $evt->[3] && ($evt->[3] == 0) &&              # Button state:  0 (indicates no mouse button was clicked).
	       defined $evt->[5] && ($evt->[5] == 1)) {              # Event flags:   1 (???).

		# Mouse movement, not an "event" in this context, return 'undef' to caller.

		return (undef);
	}
	elsif (defined $evt->[0] && ($evt->[0] == 1) &&   # Event_Type: 1 (keyboard event)
	       defined $evt->[1] && ($evt->[1] == 1)) {   # Key_Down:   1 (key pressed)

		# Keyboard key pressed, may be an "event" in this context, pass through...

		undef;
	}
	else {

		# Unmatched event, return 'undef' to caller.

		return (undef);
	}

	# ______________________________________________________
	# CONTEXT BASED BRANCH DECISION TABLE
	# ______________________________________________________
	#
	#   Possible values of 'edt_ctxt':
	#
	#     __________		___________
	#     CTXT Value		Description
	#     __________		___________
	#     EDT_CTXT_DEFAULT		Default behavior, begins at start. Keystrokes cause events within editor display like scrolling.
	#     EDT_CTXT_INSERT		Insert a string of characters at a given position within file.
	#     EDT_CTXT_SEARCH		Search for a string of characters within file.

	my $func = '';

	foreach my $func_nm (keys %{ $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} } }) {

		foreach my $func_evt (@{ $self->{'evt_sig'}->{ $arg->{'edt_ctxt'} }->{ $func_nm } }) {

			if ( ( ($func_evt->[0] eq '') || (! ($func_evt->[0] eq '') && ($func_evt->[0] eq $evt->[0]) ) ) && 
			     ( ($func_evt->[1] eq '') || (! ($func_evt->[1] eq '') && ($func_evt->[1] eq $evt->[1]) ) ) && 
			     ( ($func_evt->[2] eq '') || (! ($func_evt->[2] eq '') && ($func_evt->[2] eq $evt->[2]) ) ) && 
			     ( ($func_evt->[3] eq '') || (! ($func_evt->[3] eq '') && ($func_evt->[3] eq $evt->[3]) ) ) && 
			     ( ($func_evt->[4] eq '') || (! ($func_evt->[4] eq '') && ($func_evt->[4] eq $evt->[4]) ) ) && 
			     ( ($func_evt->[5] eq '') || (! ($func_evt->[5] eq '') && ($func_evt->[5] eq $evt->[5]) ) ) && 
			     ( ($func_evt->[6] eq '') || (! ($func_evt->[6] eq '') && ($func_evt->[6] eq $evt->[6]) ) ) ) {

				$func = $func_nm;

				# $self->{'obj'}->{'debug'}->errmsg ("FUNCTION MATCHED '" . $func_nm . "'.");
			}
			# else {
			# 
			# 	for (my $idx = 0; $idx < 6; $idx++) {
			# 
			# 		if (! exists  $func_evt->[$idx] || 
			# 		    ! defined $func_evt->[$idx]) {
			# 
			# 			$func_evt->[$idx] = "<undef>";
			# 		}
			# 
			# 		if (! exists  $evt->[$idx] || 
			# 		    ! defined $evt->[$idx]) {
			# 
			# 			$evt->[$idx] = "<undef>";
			# 		}
			# 
			# 		$objDebug->errmsg 
			# 		  (sprintf ("Event array field " . $idx . ": %10.10s %10.10s", $func_evt->[$idx], $evt->[$idx]));
			# 	}
			# }
		}
	}

	# $objDebug->errmsg ("at bottom, edt_ctxt=" . $arg->{'edt_ctxt'} . ".");

	if (! defined $func || 
	             ($func eq '')) 
	     { return (undef); }
	else { return ($func); }
}

sub evt_dispatch {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to evt_dispatch() failed, argument must be hash reference"; }

	if (! exists  $arg->{'evt_nm'} || 
	    ! defined $arg->{'evt_nm'} || 
	             ($arg->{'evt_nm'} eq '')) 
		{ die "Call to evt_dispatch() failed, value associated w/ key 'evt_nm' must be array ref"; }

	if (! exists  $arg->{'edt_ctxt'} || 
	    ! defined $arg->{'edt_ctxt'} || 
	             ($arg->{'edt_ctxt'} eq '')) 
		{ die "Call to evt_dispatch() failed, value associated w/ key 'edt_ctxt' was undef or empty string"; }

	if (! exists  $arg->{'evt'} || 
	    ! defined $arg->{'evt'} || 
	             ($arg->{'evt'} eq '') || 
	      ! (ref ($arg->{'evt'}) eq 'ARRAY')) 
		{ die "Call to evt_dispatch() failed, value associated w/ key 'evt' must be array ref"; }

	my $objCharMap = $self->{'obj'}->{'charmap'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	if (exists  $self->{'cb'} && 
	    defined $self->{'cb'} && 
	      (ref ($self->{'cb'}) eq 'HASH') && 
	    exists  $self->{'cb'}->{ $arg->{'edt_ctxt'} } && 
	    defined $self->{'cb'}->{ $arg->{'edt_ctxt'} } && 
	      (ref ($self->{'cb'}->{ $arg->{'edt_ctxt'} }) eq 'HASH') && 
	    exists  $self->{'cb'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }  && 
	    defined $self->{'cb'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }  && 
	      (ref ($self->{'cb'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }) eq 'CODE')) {

		# Call the subroutine associated with this event (callback routine).

		$self->{'cb'}->{ $arg->{'edt_ctxt'} }->{ $arg->{'evt_nm'} }->();
		return (1);
	}
	else {

		return (0);
	}
}

# ______________________________________________________________________________


END { undef; }
1;


__END__


=head1 NAME

ZHex::Event (ZHex/Event.pm) - Event Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

ZHex::Event contains event handler callback subroutines for the ZebraHex 
Editor. Events (in this context) are almost entirely related user 
actions within the interface provided by the hex editor (accessed via 
the console).

Usage:

f

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 init
Method init()...
= cut

=head2 register_callback
Method register_callback()...
= cut

=head2 register_evt_sig
Method register_evt_sig()...
= cut

=head2 gen_evt_array
Method gen_evt_array()...
= cut

=head2 evt_map
Method evt_map()...
= cut

=head2 evt_dispatch
Method evt_dispatch()...
= cut

=head1 AUTHOR

Double Z, C<< <zacharyz at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ZHex at rt.cpan.org>, or 
via the web interface: L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ZHex>.  
I will be notified, and then you'll automatically be notified of progress on 
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ZHex

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ZHex>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ZHex>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ZHex>

=item * Search CPAN

L<http://search.cpan.org/dist/ZHex/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Double Z.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;

