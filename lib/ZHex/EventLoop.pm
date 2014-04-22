#!/usr/bin/perl -w

package ZHex::EventLoop;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     obj_init 
     check_args 
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

use Time::HiRes qw(usleep tv_interval);

# Functions: Start-Up/Initialization.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Global variable declarations.

sub init {

	my $self = shift;

	$self->{'FLAG_QUIT'} = 0;            # Flag controls exit from main event loop.

	$self->{'mouse_over_char'}   = '';   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_attr'}   = '';   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_x'}      =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_y'}      =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_x_prev'} =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_y_prev'} =  0;   # Mouse handling: position, character, attributes.

	$self->{'ct_evt_functional'} = 0;    # Counters: ...
	$self->{'evt_history'} = [];         # Event history (makes 'undo' possible).
	$self->{'evt'} = [];

	return (1);
}

# Functions: Event Processing Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   evt_read()			Read/filter event information from console input buffer, return relevant events to caller.
#   evt_filter()		...
#   evt_mouse()			...
#   evt_loop()			...

sub evt_read {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'evt_read',
	     'test' => 
		[{'evt_stack' => 'arrayref'}] });

	my $objConsole = $self->{'obj'}->{'console'};

	# Function: GetEvents() 
	#   Returns the number of unread input events in the console's 
	#   input buffer (or "undef" on errors). 

	CONSOLE_EVENT: 
	  while (my $rv = $objConsole->{'CONS_IN'}->GetEvents()) {

		# Function: Input() 
		#   Reads an event from the input buffer. Returns a list of values 
		#   related to the type of event returned. The two event types are 
		#   keyboard and mouse. This method will return "undef" on errors. 

		my $evt = [];
		@{ $evt } = $objConsole->{'CONS_IN'}->Input();

		# Check for mouse pointer movement events/superflous events.

		if ($self->evt_filter ({'evt' => $evt})) {

			# Back to the top, skipping the 'push' statement below.

			next CONSOLE_EVENT;
		}
		elsif ($self->evt_mouse ({'evt' => $evt})) {

			# Back to the top, skipping the 'push' statement below.

			next CONSOLE_EVENT;
		}

		# Add event to list of events (returned to caller).

		push @{ $arg->{'evt_stack'} }, $evt;
	}

	if (scalar (@{ $arg->{'evt_stack'} }) > 0) 
	     { return (1); }
	else { return (undef); }
}

sub evt_filter {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'evt_filter',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	# Check for keyboard "key up" events:
	#   These events cloud the debugging display, filter them from event stream.

	if (defined $arg->{'evt'}->[0] && ($arg->{'evt'}->[0] == 1) &&   # Event_Type: 1 (keyboard event)
	    defined $arg->{'evt'}->[1] && ($arg->{'evt'}->[1] == 0)) {   # Key_Down:   1 (key pressed)

		return (1);
	}

	return (0);
}

sub evt_mouse {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'evt_mouse',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	my $objConsole = $self->{'obj'}->{'console'};
	my $objMouse   = $self->{'obj'}->{'mouse'};

	# Check for mouse pointer movement events:
	#   These events must be handled out-of-band (immediately).

	if (defined $arg->{'evt'}->[0] && ($arg->{'evt'}->[0] == 2) &&              # Event_Type:    2 (indicates 'mouse' event).
	    defined $arg->{'evt'}->[1] && ($arg->{'evt'}->[1] =~ /^\d\d?\d?$/) &&   # X Coordinate:  One to three digits.
	    defined $arg->{'evt'}->[2] && ($arg->{'evt'}->[2] =~ /^\d\d?\d?$/) &&   # Y Coordinate:  One to three digits.
	    defined $arg->{'evt'}->[3] && ($arg->{'evt'}->[3] == 0) &&              # Button state:  0 (indicates no mouse button was clicked).
	    defined $arg->{'evt'}->[5] && ($arg->{'evt'}->[5] == 1)) {              # Event flags:   1 (???).

		# Check to see if mouse pointer has moved enough to change either the X or Y coordinate.

		if (($arg->{'evt'}->[1] eq $self->{'mouse_over_x'}) && 
		    ($arg->{'evt'}->[2] eq $self->{'mouse_over_y'})) {

			return (0);
		}
	}
	else {

		return (0);
	}

	# Pointer movement caused one (or both) X,Y coordinates to change: 
	#
	#   1) Copy previous X,Y coordinates of mouse pointer to mouse_over_x_prev/mouse_over_y_prev.
	#   2) Store new X,Y coordinates of mouse pointer in mouse_over_x/mouse_over_y.
	#   3) Update display console to indicate new position of mouse pointer.

	$self->{'mouse_over_x_prev'} = $self->{'mouse_over_x'};
	$self->{'mouse_over_y_prev'} = $self->{'mouse_over_y'};
	$self->{'mouse_over_x'}	     = $arg->{'evt'}->[1];
	$self->{'mouse_over_y'}      = $arg->{'evt'}->[2];

	$objMouse->mouse_over 
	  ({ 'mouse_over_x'      => $self->{'mouse_over_x'}, 
	     'mouse_over_y'      => $self->{'mouse_over_y'}, 
	     'mouse_over_x_prev' => $self->{'mouse_over_x_prev'}, 
	     'mouse_over_y_prev' => $self->{'mouse_over_y_prev'} });

	return (1);
}

sub evt_loop {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};
	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objEvent   = $self->{'obj'}->{'event'};

	# ___________________________________________________________________________________
	# LOOP: READ CONSOLE EVENTS      [w/ CALL TO evt_read()]
	#       PROCESS CONSOLE EVENTS   [w/ CALL TO FUNCTION LISTED IN EVENT HANDLERS TABLE]
	#       SLEEP ON INACTIVITY      [w/ CALL TO usleep ()]
	#
	#   No tests performed here. Examine the [6 fields which contain] event
	#   information, make blind call to function associated with the key(s)
	#   [or mouse button/wheel] pressed...
	# ___________________________________________________________________________________

	my $microsec     =  1_000;   # 1/1000th second ( 1 microsecond)
	my $microsec_x5  =  5_000;   # 1/200th second  ( 5 microseconds)
	my $microsec_x10 = 10_000;   # 1/100th second  (10 microseconds)
	my $microsec_x50 = 50_000;   # 1/20th second   (50 microseconds)

	my $evt_stack = [];

	EVENT_LOOP: 
	  while (! ($self->{'FLAG_QUIT'} == 1)) {

		# Read events from console.

		my $rv = $self->evt_read ({ 'evt_stack' => $evt_stack });

		if (! defined $evt_stack || 
		             ($evt_stack eq '') || 
		    (scalar (@{ $evt_stack }) < 1)) {

			# No events, sleep 5 microseconds.

			usleep ($microsec_x5);
			next EVENT_LOOP;
		}

		# Process event objects on the event stack (first in first out).

		EVENT_STACK: 
		  foreach my $evt (shift @{ $evt_stack }) {

			# Call evt_map(): determine if @evt matches an event (in the present context).

			my $evt_nm = 
			  $objEvent->evt_map 
			    ({ 'edt_ctxt' => $objEditor->{'edt_ctxt'}, 
			       'evt'      => $evt });

			# Store the event (temporarily) in self for access by: 
			#   Debugging information display subroutines.
			#   Event handlers (callback subroutines).

			# $self->{'evt'} = $evt;   # <--- TO DO: Feed this directly to Debug.pm...

			if (! defined $evt_nm || 
			              $evt_nm eq '' || 
			           ! ($evt_nm =~ /^[\w\_]+?$/)) {

				$objDebug->errmsg ("Unsupported function: evt_map() returned undef.");
				next EVENT_STACK;
			}

			# Dispatch the event callback routine registered to handle this event.

			if ($objEvent->evt_dispatch 
			      ({ 'evt_nm'   => $evt_nm, 
			         'edt_ctxt' => $objEditor->{'edt_ctxt'}, 
			         'evt'      => $evt })) {

				$objDebug->errmsg ("Call to evt_dispatch w/ argument '" . $evt_nm . "' returned w/ success.");
			}
			else {

				$objDebug->errmsg ("Call to evt_dispatch w/ argument '" . $evt_nm . "' returned w/ failure.");
				next EVENT_STACK;
			}
		}
		continue {

			UPDATE_TERMINAL: {

				# Store the current display data structure (before updating the display).

				$objDisplay->dsp_prev_set 
				  ({ 'dsp_prev' => $objDisplay->{'dsp'} });

				# Update the editor display/debugging information/cursor, write to the display console.

				# $objDisplay->dsp_set 
				#   ({ 'dsp' => $objDisplay->generate_editor_display ({ 'evt' => \@{ [ '', '', '', '', '', '' ] } }) });

				$objDisplay->dsp_set 
				  ({ 'dsp' => $objDisplay->generate_editor_display ({ 'evt' => $evt }) });

				$objConsole->w32cons_refresh_display 
				  ({ 'dsp'      => $objDisplay->{'dsp'}, 
				     'dsp_prev' => $objDisplay->{'dsp_prev'}, 
				     'dsp_xpad' => $objDisplay->{'dsp_xpad'}, 
				     'dsp_ypad' => $objDisplay->{'dsp_ypad'},
				     'd_width'  => $objDisplay->{'d_width'} });

				$objCursor->curs_display 
				  ({ 'dsp_xpad' => $objDisplay->{'dsp_xpad'}, 
				     'dsp_ypad' => $objDisplay->{'dsp_ypad'}, 
				     'force'    => 0 });
			}
		}
	}

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::EventLoop (ZHex/EventLoop.pm) - Event Loop Module, ZHex Editor.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

The ZHex::EventLoop module provides functions for event handling, 
including the main event loop.

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objEventLoop = $self->{'obj'}->{'eventloop'};
    $objEventLoop->evt_read();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 new
Method new()...
= cut

=head2 init
Method init()...
= cut

=head2 obj_init
Method obj_init()...
= cut

=head2 evt_loop
Method evt_loop()...
= cut

=head2 evt_read
Method evt_read()...

=head2 evt_filter
Method evt_filter()...

=head2 evt_mouse
Method evt_mouse()...

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

