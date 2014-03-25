#!/usr/bin/perl

package ZHex::EventLoop;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::BoilerPlate qw(new obj_init $VERS);

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

	# Event loop context: depending upon the state of the 'CTXT' 
	# variable, keystrokes have different meanings.

	$self->{'CTXT'} = 'DEFAULT';	# In DEFAULT context, keystrokes mostly cause events.
					# In SEARCH  context, keystrokes are added to the search string until the ENTER key is pressed.
					# In INSERT  context, keystrokes are added to the file being edited, until the ESCAPE key is pressed.

	# Flag controls exit from main event loop.

	$self->{'FLAG_QUIT'} = 0;

	# Mouse handling: position, character, attributes.

	$self->{'mouse_over_char'}   = '';   # ...
	$self->{'mouse_over_attr'}   = '';   # ...
	$self->{'mouse_over_x'}      =  0;   # ...
	$self->{'mouse_over_y'}      =  0;   # ...
	$self->{'mouse_over_x_prev'} =  0;   # ...
	$self->{'mouse_over_y_prev'} =  0;   # ...

	# Counters: ...

	$self->{'ct_evt_functional'} = 0;   # ...

	# Event callback subroutine references.

	$self->{'cb'} = {};

	# Event history (makes 'undo' possible).

	$self->{'evt_history'} = [];

	return (1);
}

# Functions: Event Processing Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   register_callback()		Register callback subroutine to handle event under certain context.
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

	$self->{'cb'}->{ $arg->{'ctxt'} }->{ $arg->{'evt_nm'} } = $arg->{'evt_cb'};

	return (1);
}

sub event_loop {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};
	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objFile    = $self->{'obj'}->{'file'};

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
			  $self->evt_map ({ 'ctxt' => $self->{'CTXT'}, 
			                    'evt'  => $evt });

			# Store the event (temporarily) in self for access by: 
			#   Debugging information display subroutines.
			#   Event handlers (callback subroutines).

			$self->{'evt'} = $evt;

			if (! defined $evt_nm || 
			              $evt_nm eq '' || 
			           ! ($evt_nm =~ /^[\w\_]+?$/)) {

				$objDebug->errmsg ("Unsupported function: <evt_map() returned undef>.");
				next EVENT_STACK;
			}

			# Check to see if a callback routine has been registered to handle this event.

			if (defined $evt_nm && 
				 ! ($evt_nm eq '') && 
				   ($evt_nm =~ /^[\w\_]+?$/) && 
			    exists  $self->{'cb'} && 
			    defined $self->{'cb'} && 
			      (ref ($self->{'cb'}) eq 'HASH') && 
			    exists  $self->{'cb'}->{ $self->{'CTXT'} } && 
			    defined $self->{'cb'}->{ $self->{'CTXT'} } && 
			      (ref ($self->{'cb'}->{ $self->{'CTXT'} }) eq 'HASH') && 
			    exists  $self->{'cb'}->{ $self->{'CTXT'} }->{$evt_nm} && 
			    defined $self->{'cb'}->{ $self->{'CTXT'} }->{$evt_nm} && 
			      (ref ($self->{'cb'}->{ $self->{'CTXT'} }->{$evt_nm}) eq 'CODE')) {

				$objDebug->errmsg ("Calling function: " . $evt_nm);
				$self->{'ct_evt_functional'}++;

				# Call the subroutine associated with this event (callback routine).

				$self->{'cb'}->{ $self->{'CTXT'} }->{$evt_nm}->();
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
			     'dsp_ypad' => $objDisplay->{'dsp_ypad'} });

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

	my $objCharMap = $self->{'obj'}->{'charmap'};
	my $objConsole = $self->{'obj'}->{'console'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objEditor  = $self->{'obj'}->{'editor'};

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
	#   Possible values of 'CTXT':
	#
	#     __________	___________
	#     CTXT Value	Description
	#     __________	___________
	#     DEFAULT		Default behavior, begins at start. Keystrokes cause events within editor display like scrolling.
	#     INSERT		Insert a string of characters at a given position within file.
	#     SEARCH		Search for a string of characters within file.

	my $func = '';
	if ($arg->{'ctxt'} eq 'DEFAULT') {

		# _______________
		# DEFAULT CONTEXT

		# QUIT, <LATIN SMALL LETTER Q> Character.
		if ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Q'}{'byte'}) 
			{ $func = 'QUIT'; } 

		# DEBUG_OFF, <LATIN SMALL LETTER D> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER D'}{'byte'}) 
			{ $func = 'DEBUG_OFF'; } 

		# DEBUG_ON, <LATIN CAPITAL LETTER D> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER D'}{'byte'}) 
			{ $func = 'DEBUG_ON'; } 

		# MOVE_BEG, <CIRCUMFLEX ACCENT> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'CIRCUMFLEX ACCENT'}{'byte'}) 
			{ $func = 'MOVE_BEG'; } 

		# MOVE_END, <DOLLAR SIGN> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'DOLLAR SIGN'}{'byte'}) 
			{ $func = 'MOVE_END'; } 
		
		# CONSCURS_INVIS, <LATIN SMALL LETTER V> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER V'}{'byte'}) 
			{ $func = 'CONSCURS_INVIS'; } 

		# CONSCURS_VISIBL, <LATIN CAPITAL LETTER V> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER V'}{'byte'}) 
			{ $func = 'CONSCURS_VIS'; } 

		# INSERT_MODE, <LATIN SMALL LETTER I> Character, [INSERT] Key.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER I'}{'byte'}) || 
		      (($evt->[3] ==  45) && 
		       ($evt->[4] ==  82) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256)) ))
			{ $func = 'INSERT_MODE'; } 

		# WRITE_DISK, <LATIN SMALL LETTER W> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER W'}{'byte'}) 
			{ $func = 'WRITE_DISK'; } 

		# SEARCH_MODE, <LATIN SMALL LETTER S> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER S'}{'byte'}) 
			{ $func = 'SEARCH_MODE'; } 

		# JUMP_TO_LINE, <LATIN CAPITAL LETTER L> Character, <NUMBER SIGN> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER L'}{'byte'})
			{ $func = 'JUMP_TO_LINE'; } 

		# INCR_CURS_CTXT, <CARRIAGE RETURN CR> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'CARRIAGE RETURN (CR)'}{'byte'}) 
			{ $func = 'INCR_CURS_CTXT'; } 

		# DECR_CURS_CTXT, [ESCAPE] Key.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'ESCAPE'}{'byte'}) 
			{ $func = 'DECR_CURS_CTXT'; } 

		# SCROLL_UP_1LN, <LATIN SMALL LETTER K> Character, <MOUSE WHEEL ROLL UP>.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER K'}{'byte'}) || 
		      (($evt->[0] == 2) && 
		       ($evt->[3] == 7864320) && 
		       ($evt->[5] == 4))) 
			{ $func = 'SCROLL_UP_1LN'; } 

		# SCROLL_UP_1PG, <LATIN CAPITAL LETTER K> Character, [PAGE UP] Key.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER J'}{'byte'}) || 
		      (($evt->[5] ==  0) && 
		       ($evt->[3] ==  33) && 
		       ($evt->[4] == 73) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256)))) 
			{ $func = 'SCROLL_UP_1PG'; } 

		# SCROLL_DOWN_1LN, <LATIN SMALL LETTER J> Character, <MOUSE WHEEL ROLL DOWN>.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER J'}{'byte'}) || 
		      (($evt->[0] == 2) && 
		       ($evt->[3] == -7864320) && 
		       ($evt->[5] == 4))) 
			{ $func = 'SCROLL_DOWN_1LN'; } 

		# SCROLL_DOWN_1PG, <LATIN CAPITAL LETTER K> Character, [SPACE] Key, [PAGE DOWN] Key.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER K'}{'byte'}) || 
		       ($evt->[5] == $objCharMap->{'chr_map'}->{'SPACE'}{'byte'}) || 
		      (($evt->[3] ==  34) && 
		       ($evt->[4] ==  81) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256)))) 
			{ $func = 'SCROLL_DOWN_1PG'; }

		# MOVE_CURS_FORWARD, [TAB] Key.
		elsif (($evt->[3] ==   9) && 
		       ($evt->[4] ==  15) && 
		       ($evt->[5] ==   9) && 
		      (($evt->[6] ==  32) || ($evt->[6] == 0))) 
			{ $func = 'MOVE_CURS_FORWARD'; }

		# MOVE_CURS_BACK, [SHIFT]+[TAB] Key(s) Combined.
		elsif (($evt->[3] ==  9) && 
		       ($evt->[4] == 15) && 
		       ($evt->[5] ==  9) && 
		      (($evt->[6] == 48) || ($evt->[6] == 16))) 
			{ $func = 'MOVE_CURS_BACK'; } 

		# MOVE_CURS_UP, [UP ARROW] Key.
		elsif (($evt->[3] ==  38) && 
		       ($evt->[4] ==  72) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256))) 
			{ $func = 'MOVE_CURS_UP'; } 

		# MOVE_CURS_DOWN, [DOWN ARROW] Key.
		elsif (($evt->[3] == 40) && 
		       ($evt->[4] == 80) && 
		       ($evt->[5] ==  0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256))) 
			{ $func = 'MOVE_CURS_DOWN'; } 

		# MOVE_CURS_LEFT, [LEFT ARROW] Key.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER H'}{'byte'}) || 
		      (($evt->[3] ==  37) && 
		       ($evt->[4] ==  75) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256)))) 
			{ $func = 'MOVE_CURS_LEFT'; } 

		# MOVE_CURS_RIGHT, [RIGHT ARROW] Key.
		elsif (($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER L'}{'byte'}) || 
		      (($evt->[3] ==  39) && 
		       ($evt->[4] ==  77) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || ($evt->[6] == 256)))) 
			{ $func = 'MOVE_CURS_RIGHT'; }

		# L_MOUSE_BUTTON, <LEFT MOUSE> Button.
		elsif (($evt->[0] == 2) && 
		       ($evt->[3] == 1)) 
			{ $func = 'L_MOUSE_BUTTON'; }

		# R_MOUSE_BUTTON, <RIGHT MOUSE> Button.
		elsif (($evt->[0] == 2) && 
		       ($evt->[3] == 2)) 
			{ $func = 'R_MOUSE_BUTTON'; }

		# DEFAULT: VSTRETCH, [CTRL][UP] Arrow key | 0 | 38 | 72 | 264| 
		# Stretch the editor display verically. vstretch()
		elsif (($evt->[3] ==  38) && 
		       ($evt->[4] ==  72) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 264))) 
			{ $func = 'VSTRETCH'; }

		# DEFAULT: VCOMPRESS, [CTRL][DN] Arrow key | 0 | 40 | 80 | 264| 
		# Compress the editor display vertcially. vcompress()
		elsif (($evt->[3] == 40) && 
		       ($evt->[4] == 80) && 
		       ($evt->[5] ==  0) && 
		      (($evt->[6] == 264))) 
			{ $func = 'VCOMPRESS'; }
	}
	elsif ($arg->{'ctxt'} eq 'INSERT') {

		# _______________
		# INSERT CONTEXT

		if ( ($evt->[5] == $objCharMap->{'chr_map'}->{'SPACE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'EXCLAMATION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'QUOTATION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'NUMBER SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DOLLAR SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'PERCENT SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'AMPERSAND'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'APOSTROPHE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT PARENTHESIS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT PARENTHESIS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'ASTERISK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'PLUS SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COMMA'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'HYPHEN-MINUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'FULL STOP'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'SOLIDUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT ZERO'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT ONE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT TWO'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT THREE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT FOUR'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT FIVE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT SIX'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT SEVEN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT EIGHT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT NINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COLON'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'SEMICOLON'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LESS-THAN SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'EQUALS SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'GREATER-THAN SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'QUESTION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COMMERCIAL AT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER A'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER B'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER C'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER D'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER E'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER F'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER G'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER H'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER I'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER J'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER K'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER L'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER M'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER N'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER O'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER P'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Q'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER R'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER S'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER T'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER U'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER V'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER W'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER X'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Y'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Z'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT SQUARE BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'REVERSE SOLIDUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT SQUARE BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'CIRCUMFLEX ACCENT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LOW LINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'GRAVE ACCENT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER A'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER B'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER C'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER D'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER E'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER F'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER G'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER H'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER I'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER J'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER K'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER L'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER M'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER N'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER O'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER P'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Q'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER R'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER S'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER T'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER U'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER V'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER W'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER X'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Y'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Z'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT CURLY BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'VERTICAL LINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT CURLY BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'TILDE'}{'byte'}) ) 
			{ $func = 'INSERT_CHAR'; }

		# SEARCH_BACKSPACE, [BACKSPACE] Key.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'BACKSPACE'}{'byte'}) 
			{ $func = 'INSERT_BACKSPACE'; }

		# SEARCH_ENTER, <CARRIAGE RETURN (CR)> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'CARRIAGE RETURN (CR)'}{'byte'}) 
			{ $func = 'INSERT_ENTER'; }

		# INSERT_ESCAPE, [ESCAPE] Key.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'ESCAPE'}{'byte'}) 
			{ $func = 'INSERT_ESCAPE'; }

		# SEARCH_L_ARROW, [Left Arrow] Key.
		elsif (($evt->[3] ==  37) && 
		       ($evt->[4] ==  75) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || 
		       ($evt->[6] == 256))) 
			{ $func = 'INSERT_L_ARROW'; }

		# SEARCH_L_ARROW, [Right Arrow] Key.
		elsif (($evt->[3] ==  39) && 
		       ($evt->[4] ==  77) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || 
		       ($evt->[6] == 256))) 
			{ $func = 'INSERT_R_ARROW'; }
	}
	elsif ($arg->{'ctxt'} eq 'SEARCH') {

		# _______________
		# SEARCH CONTEXT

		# Event_Type 1: Keyboard event.

		if ( ($evt->[5] == $objCharMap->{'chr_map'}->{'SPACE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'EXCLAMATION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'QUOTATION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'NUMBER SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DOLLAR SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'PERCENT SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'AMPERSAND'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'APOSTROPHE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT PARENTHESIS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT PARENTHESIS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'ASTERISK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'PLUS SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COMMA'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'HYPHEN-MINUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'FULL STOP'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'SOLIDUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT ZERO'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT ONE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT TWO'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT THREE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT FOUR'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT FIVE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT SIX'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT SEVEN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT EIGHT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'DIGIT NINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COLON'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'SEMICOLON'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LESS-THAN SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'EQUALS SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'GREATER-THAN SIGN'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'QUESTION MARK'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'COMMERCIAL AT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER A'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER B'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER C'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER D'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER E'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER F'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER G'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER H'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER I'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER J'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER K'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER L'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER M'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER N'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER O'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER P'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Q'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER R'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER S'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER T'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER U'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER V'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER W'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER X'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Y'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN CAPITAL LETTER Z'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT SQUARE BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'REVERSE SOLIDUS'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT SQUARE BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'CIRCUMFLEX ACCENT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LOW LINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'GRAVE ACCENT'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER A'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER B'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER C'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER D'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER E'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER F'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER G'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER H'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER I'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER J'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER K'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER L'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER M'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER N'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER O'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER P'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Q'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER R'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER S'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER T'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER U'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER V'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER W'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER X'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Y'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LATIN SMALL LETTER Z'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'LEFT CURLY BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'VERTICAL LINE'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'RIGHT CURLY BRACKET'}{'byte'}) || 
		     ($evt->[5] == $objCharMap->{'chr_map'}->{'TILDE'}{'byte'}) ) 
			{ $func = 'SEARCH_CHAR'; }

		# SEARCH_BACKSPACE, [BACKSPACE] Key.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'BACKSPACE'}{'byte'}) 
			{ $func = 'SEARCH_BACKSPACE'; }

		# SEARCH_ENTER, <CARRIAGE RETURN (CR)> Character.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'CARRIAGE RETURN (CR)'}{'byte'}) 
			{ $func = 'SEARCH_ENTER'; }

		# SEARCH_ESCAPE, [ESCAPE] Key.
		elsif ($evt->[5] == $objCharMap->{'chr_map'}->{'ESCAPE'}{'byte'}) 
			{ $func = 'SEARCH_ESCAPE'; }

		# SEARCH_L_ARROW, [Left Arrow] Key.
		elsif (($evt->[3] ==  37) && 
		       ($evt->[4] ==  75) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || 
		       ($evt->[6] == 256))) 
			{ $func = 'SEARCH_L_ARROW'; }

		# SEARCH_L_ARROW, [Right Arrow] Key.
		elsif (($evt->[3] ==  39) && 
		       ($evt->[4] ==  77) && 
		       ($evt->[5] ==   0) && 
		      (($evt->[6] == 288) || 
		       ($evt->[6] == 256))) 
			{ $func = 'SEARCH_R_ARROW'; }
	}

	if (! defined $func || 
	             ($func eq '')) 
	     { return (undef); }
	else { return ($func); }
}

sub adjust_display {

	my $self = shift;

	INIT_EDITOR_DISPLAY_ELEMENTS: {

		# 1) Initialize editor display elements: 
		#      X,Y coordinates within display, padding, enabled.
		# 2) Initialize colorization elements.
		#      Associate color elements with editor display elements.
		# 3) Store references to: 
		#      Display elements data structure, 
		#      Colorization elements data structure.

		$self->{'obj'}->{'display'}->d_elements_set 
		  ({ 'd_elements' => $self->{'obj'}->{'display'}->d_elements_init() });

		$self->{'obj'}->{'display'}->c_elements_set 
		  ({ 'c_elements' => $self->{'obj'}->{'display'}->c_elements_init() });
	}

	WRITE_EDITOR_DISPLAY_TO_CONSOLE: {

		# 1) Generate the editor display, store within display object 
		#    under key 'display' (confusing choice of variable names,  
		#    I know).
		# 2) Write editor display to display console.

		$self->{'obj'}->{'display'}->dsp_set 
		  ({ 'dsp' => $self->{'obj'}->{'display'}->generate_editor_display() });

		$self->{'obj'}->{'console'}->w32cons_refresh_display 
		  ({ 'dsp'      => $self->{'obj'}->{'display'}->{'dsp'}, 
		     'dsp_prev' => $self->{'obj'}->{'display'}->{'dsp_prev'}, 
		     'dsp_xpad' => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad' => $self->{'obj'}->{'display'}->{'dsp_ypad'} });

		# 1) Colorize elements of the editor display.
		# 2) Highlight the cursor within the editor display.

		$self->{'obj'}->{'console'}->colorize_display 
		  ({ 'c_elements' => $self->{'obj'}->{'display'}->active_c_elements(), 
		     'dsp_xpad'   => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad'   => $self->{'obj'}->{'display'}->{'dsp_ypad'} });

		$self->{'obj'}->{'cursor'}->curs_display 
		  ({ 'dsp_xpad' => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad' => $self->{'obj'}->{'display'}->{'dsp_ypad'}, 
		     'force'    => 1 });
	}

	return (1)
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

    use ZHex;

    my $objEventLoop = ZHex->new();
    ...

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

=head2 read_evt
Method read_evt()...
= cut

=head2 register_callback
Method register_callback()...
= cut


=head1 AUTHOR

Double Z, C<< <zacharyz at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ZHex at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ZHex>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




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

