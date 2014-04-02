#!/usr/bin/perl

package ZHex::EventLoop;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     obj_init 
     $VERS);

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

	                                     # Event loop context: depending upon the state of the 'ctxt' 
	                                     # variable, keystrokes have different meanings.
	$self->{'FLAG_QUIT'} = 0;            # Flag controls exit from main event loop.
	$self->{'mouse_over_char'}   = '';   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_attr'}   = '';   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_x'}      =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_y'}      =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_x_prev'} =  0;   # Mouse handling: position, character, attributes.
	$self->{'mouse_over_y_prev'} =  0;   # Mouse handling: position, character, attributes.

	$self->{'ct_evt_functional'} = 0;    # Counters: ...
	$self->{'evt_history'} = [];         # Event history (makes 'undo' possible).

	$self->{'cb'} = {};                  # Event callback subroutine references.
	$self->{'cb'}->{'DEFAULT'} = {};
	$self->{'cb'}->{'INSERT'}  = {};
	$self->{'cb'}->{'SEARCH'}  = {};

	$self->{'evt_sig'} = {};
	$self->{'evt_sig'}->{'DEFAULT'} = {};
	$self->{'evt_sig'}->{'INSERT'}  = {};
	$self->{'evt_sig'}->{'SEARCH'}  = {};

	return (1);
}

# Functions: Event Processing Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   register_callback()		Register callback subroutine to handle event under certain context.
#   register_evt_sig()		Register event signature (unique values of evt array that identify different keystrokes).
#   gen_evt_array()		...
#   event_loop()		...
#   read_evt()			Read/filter event information from console input buffer, return relevant events to caller.
#   evt_map()			...

sub register_callback {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to register_callback() failed, argument must be hash reference"; }

	if (! exists  $arg->{'ctxt'} || 
	    ! defined $arg->{'ctxt'} || 
	             ($arg->{'ctxt'} eq '')) 
		{ die "Call to register_callback() failed, value associated w/ key 'ctxt' was undef/empty string"; }

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

	$self->{'cb'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} } = $arg->{'evt_cb'};

	foreach my $evt_sig (@{ $arg->{'evt'} }) {

		# Store event signature in wherever it gets stored.

		$self->register_evt_sig 
		  ({ 'ctxt'   => $arg->{'ctxt'}, 
		     'evt_nm' => $arg->{'evt_nm'}, 
		     'evt'    => $evt_sig });
	}

	# $self->{'obj'}->{'debug'}->errmsg ("Registered callback for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'ctxt'} . "'.\n");
	# warn ("Registered callback for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'ctxt'} . "').");

	return (1);
}

sub register_evt_sig {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to register_evt_sig() failed, argument must be hash reference"; }

	if (! exists  $arg->{'ctxt'} || 
	    ! defined $arg->{'ctxt'} || 
	             ($arg->{'ctxt'} eq '')) 
		{ die "Call to register_evt_sig() failed, value associated w/ key 'ctxt' must not be undef/empty"; }

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

	if (exists  $self->{'evt_sig'} && 
	    defined $self->{'evt_sig'} && 
	      (ref ($self->{'evt_sig'}) eq 'HASH') && 
	    exists  $self->{'evt_sig'}->{ $arg->{'ctxt'} } && 
	    defined $self->{'evt_sig'}->{ $arg->{'ctxt'} } && 
	      (ref ($self->{'evt_sig'}->{ $arg->{'ctxt'} }) eq 'HASH')) {

		if (! (exists  $self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} }) || 
		    ! (defined $self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} }) || 
		       ! (ref ($self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} }) eq 'ARRAY')) { 

			$self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} } = [];
		}

		push @{ $self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} } }, 
		     $arg->{'evt'};
	}

	# $self->{'obj'}->{'debug'}->errmsg ("Registered event signature for '" . $arg->{'evt_nm'} . "'.\n");
	# warn ("Registered event signature for '" . $arg->{'evt_nm'} . "' (context='" . $arg->{'ctxt'} . "'.");

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

sub event_loop {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};
	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	# ___________________________________________________________________________________
	# LOOP: READ CONSOLE EVENTS      [w/ CALL TO read_evt()]
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

		my $rv = $self->read_evt ({ 'evt_stack' => $evt_stack });

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

			# Call evt_map() to determine if this event means something in the given context.

			my $evt_nm = 
			  $self->evt_map ({ 'ctxt' => $objEditor->{'ctxt'}, 
			                    'evt'  => $evt });

			# Store the event (temporarily) in self for access by: 
			#   Debugging information display subroutines.
			#   Event handlers (callback subroutines).

			$self->{'evt'} = $evt;   # <--- TO DO: Feed this directly to Debug.pm...

			if (! defined $evt_nm || 
			              $evt_nm eq '' || 
			           ! ($evt_nm =~ /^[\w\_]+?$/)) {

				$objDebug->errmsg ("Unsupported function: <evt_map() returned undef>.");
				next EVENT_STACK;
			}

			# Check to see if a callback routine has been registered to handle this event.

			if (exists  $self->{'cb'} && 
			    defined $self->{'cb'} && 
			      (ref ($self->{'cb'}) eq 'HASH') && 
			    exists  $self->{'cb'}->{ $objEditor->{'ctxt'} } && 
			    defined $self->{'cb'}->{ $objEditor->{'ctxt'} } && 
			      (ref ($self->{'cb'}->{ $objEditor->{'ctxt'} }) eq 'HASH') && 
			    exists  $self->{'cb'}->{ $objEditor->{'ctxt'} }->{$evt_nm} && 
			    defined $self->{'cb'}->{ $objEditor->{'ctxt'} }->{$evt_nm} && 
			      (ref ($self->{'cb'}->{ $objEditor->{'ctxt'} }->{$evt_nm}) eq 'CODE')) {

				$objDebug->errmsg ("Calling function '" . $evt_nm . "' in context '" . $objEditor->{'ctxt'} . "'.");
				$self->{'ct_evt_functional'}++;

				# Call the subroutine associated with this event (callback routine).

				$self->{'cb'}->{ $objEditor->{'ctxt'} }->{$evt_nm}->();
				push @{ $self->{'evt_history'} }, $evt_nm;   # Push event onto 'evt_history'.
			}
			else {

				# Store the event (temporarily) in self for access by: 
				#   Debugging information display subroutines.

				$objDebug->errmsg ("Unsupported function: <" . $evt_nm . ">");
				next EVENT_STACK;
			}
		}
		continue {

			# Store the current display data structure (before updating the display).

			$objDisplay->dsp_prev_set 
			  ({ 'dsp_prev' => $objDisplay->{'dsp'} });

			# Update the editor display/debugging information/cursor, write to the display console.

			$objDisplay->dsp_set 
			  ({ 'dsp' => $objDisplay->generate_editor_display() });

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

	return (1);
}

sub read_evt {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to read_evt() failed, argument must be hash reference"; }

	if (! exists  $arg->{'evt_stack'} || 
	    ! defined $arg->{'evt_stack'} || 
	             ($arg->{'evt_stack'} eq '') || 
	      ! (ref ($arg->{'evt_stack'}) eq 'ARRAY')) 
		{ die "Call to read_evt() failed, value associated w/ key 'evt_stack' must be array ref"; }

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

		my @evt = $objConsole->{'CONS_IN'}->Input();

		# Check for keyboard "key up" events:
		#   These events are clogging up the debugging display, filter them from event stream.

		if (defined $evt[0] && ($evt[0] == 1) &&   # Event_Type: 1 (keyboard event)
		    defined $evt[1] && ($evt[1] == 0)) {   # Key_Down:   1 (key pressed)

			next CONSOLE_EVENT;
		}

		# Check for mouse pointer movement events:
		#   These events must be handled out-of-band (immediately).

		if (defined $evt[0] && ($evt[0] == 2) &&              # Event_Type:    2 (indicates 'mouse' event).
		    defined $evt[1] && ($evt[1] =~ /^\d\d?\d?$/) &&   # X Coordinate:  One to three digits.
		    defined $evt[2] && ($evt[2] =~ /^\d\d?\d?$/) &&   # Y Coordinate:  One to three digits.
		    defined $evt[3] && ($evt[3] == 0) &&              # Button state:  0 (indicates no mouse button was clicked).
		    defined $evt[5] && ($evt[5] == 1)) {              # Event flags:   1 (???).

			# Check to see if mouse pointer has moved enough to change either the X or Y coordinate.

			if (! ($evt[1] eq $self->{'mouse_over_x'}) || 
			    ! ($evt[2] eq $self->{'mouse_over_y'})) {

				# Pointer movement caused one (or both) X,Y coordinates to change: 
				#
				#   1) Copy previous X,Y coordinates of mouse pointer to mouse_over_x_prev/mouse_over_y_prev.
				#   2) Store new X,Y coordinates of mouse pointer in mouse_over_x/mouse_over_y.
				#   3) Update display console to indicate new position of mouse pointer.

				$self->{'mouse_over_x_prev'} = $self->{'mouse_over_x'};
				$self->{'mouse_over_y_prev'} = $self->{'mouse_over_y'};
				$self->{'mouse_over_x'}	     = $evt[1];
				$self->{'mouse_over_y'}      = $evt[2];

				$objConsole->mouse_over 
				  ({ 'mouse_over_x'      => $self->{'mouse_over_x'}, 
				     'mouse_over_y'      => $self->{'mouse_over_y'}, 
				     'mouse_over_x_prev' => $self->{'mouse_over_x_prev'}, 
				     'mouse_over_y_prev' => $self->{'mouse_over_y_prev'} });
			}

			# Back to the top, skipping the 'push' statement below.

			next CONSOLE_EVENT;
		}

		# Add event to list of events (returned to caller).

		push @{ $arg->{'evt_stack'} }, \@evt;
	}

	if (scalar (@{ $arg->{'evt_stack'} }) > 0) 
	     { return (1); }
	else { return (undef); }
}

sub evt_map {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to evt_map() failed, argument must be hash reference"; }

	if (! exists  $arg->{'ctxt'} || 
	    ! defined $arg->{'ctxt'} || 
	             ($arg->{'ctxt'} eq '')) 
		{ die "Call to evt_map() failed, value associated w/ key 'ctxt' was undef or empty string"; }

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
	#   Possible values of 'ctxt':
	#
	#     __________	___________
	#     CTXT Value	Description
	#     __________	___________
	#     DEFAULT		Default behavior, begins at start. Keystrokes cause events within editor display like scrolling.
	#     INSERT		Insert a string of characters at a given position within file.
	#     SEARCH		Search for a string of characters within file.

	my $func = '';

	foreach my $func_nm (keys %{ $self->{'evt_sig'}->{ $arg->{'ctxt'} } }) {

		foreach my $func_evt (@{ $self->{'evt_sig'}->{ $arg->{'ctxt'} }->{ $func_nm } }) {

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
			# 		# $objDebug->errmsg 
			# 		#   (sprintf ("Event array field " . $idx . ": %10.10s %10.10s", $func_evt->[$idx], $evt->[$idx]));
			# 	}
			# }
		}
	}

	if (! defined $func || 
	             ($func eq '')) 
	     { return (undef); }
	else { return ($func); }
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::EventLoop (ZHex/EventLoop.pm) - EventLoop Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::EventLoop module provides functions for event handling, 
including the main event loop. This module also provides functions for 
registering callback subroutines to handle various event types, and 
provides for the abstraction of 'context' which simply means that 
different callback subroutines will be called based upon which context 
the hex editor is currently operating within.

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objEventLoop = $self->{'obj'}->{'eventloop'};
    $objEventLoop->read_evt();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 event_loop
Method event_loop()...
= cut

=head2 evt_map
Method evt_map()...
= cut

=head2 init
Method init()...
= cut

=head2 gen_evt_array
Method gen_evt_array()...
= cut

=head2 read_evt
Method read_evt()...
= cut

=head2 register_callback
Method register_callback()...
= cut

=head2 register_evt_sig
Method register_evt_sig()...
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

