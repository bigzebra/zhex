#!/usr/bin/perl

package ZHex::Event;

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

# Functions: Start-Up/Initialization.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Global variable declarations.

sub init {

	my $self = shift;

	# Hash reference holds callback subroutines: registered as event 
	# handlers via ZHex::EventLoop->register_callback() function.

	$self->{'cb'} = {};
	$self->{'cb'}->{'DEFAULT'} = {};   # DEFAULT context event handlers (callback subroutines).
	$self->{'cb'}->{'INSERT'}  = {};   # INSERT  context event handlers (callback subroutines).
	$self->{'cb'}->{'SEARCH'}  = {};   # SEARCH  context event handlers (callback subroutines).

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;
	$self->{'curs_ctxt_prev'} = 0;

	return (1);
}

# Functions: Event Handling Functions.
#
#   ____				___________
#   NAME				DESCRIPTION
#   ____				___________
#   register_event_callbacks()		Define callback subroutines for named functions.

sub register_event_callbacks {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};
	my $objCursor    = $self->{'obj'}->{'cursor'};

	# Development: Unicode character names that should be useful.
	#
	# _________			______
	# Character			Action
	# _________			______
	# 'BACKSPACE'			Erase one character.
	# 'LINE FEED (LF)'		Confirmation.
	# 'CARRIAGE RETURN (CR)'	Confirmation.
	# 'DOLLAR SIGN'			Skip to EOF (end of file).

	# _____________________________________________________________________________________________________
	# EVENT DRIVEN FUNCTION TABLE: TABLE OF WRAPPER FUNCTIONS PROVIDING UNIFORM NAMES/API TO EVENT HANDLERS
	#   'DEFAULT' Context Functions:
	# _______ _______________   ___________________ _____________________ ____________________                       _________________ 
	# CONTEXT FUNCTION NAME     KEYBOARD MAPPING    |CHAR|VKCD|VSCD|CTRL| FUNCTION DESCRIPTION                       INTERNAL FUNCTION 
	# _______ _______________   ___________________ |____|____|____|____| ____________________                       _________________ 
	# DEFAULT QUIT              [q] Key (Low Case)  |113 |  - |  - |  - | Quit                                       quit() 
	# DEFAULT CONSCURS_INVIS    SMALL LETTER V      |... |  - |  - |  - | Make (console cursor) invisible            w32cons_cursor_invisible() 
	# DEFAULT CONSCURS_VIS      CAPITAL LETTER V    |... |  - |  - |  - | Make (console cursor) visible              w32cons_cursor_visible() 
	# DEFAULT INSERT_MODE       [i] Key (Low Case)  |105 |  - |  - |  - | Insert (Begin Edit At Cursor)              insert_mode()
	# DEFAULT INSERT_MODE       [INSERT] Key        |  0 | 45 | 82 |288 | Insert                                     insert_mode() 
	# DEFAULT INSERT_MODE       [INSERT] Key        |  0 | 45 | 82 |256 | Insert                                     insert_mode() 
# >>>	# DEFAULT WRITE_DISK        [w] Key (Low Case)  |119 |  - |  - |  - | Write  (Write Changes to Disk)             *** NOT IMPLEMENTED *** 
	# DEFAULT SEARCH_MODE       [s] Key (Low Case)  |115 |  - |  - |  - | Search (Enter String  to Search For)       search_mode()
# >>>	# DEFAULT JUMP_TO_LINE      [L] Key (Upp Case)  |... |  - |  - |  - | Line Number (Jump To)                      *** NOT IMPLEMENTED *** 
# >>>	# DEFAULT COPY_REGION       [CTRL][C]           |  ? |  ? |  ? |  ? | Copy Highlighted/Selected Region           *** NOT IMPLEMENTED *** 
# >>>	# DEFAULT CUT_REGION        [CTRL][X]           |  ? |  ? |  ? |  ? | Cut  Highlighted/Selected Region           *** NOT IMPLEMENTED *** 
# >>>	# DEFAULT PASTE_BUFFER      [CTRL][V]           |  ? |  ? |  ? |  ? | Paste Contents Of Buffer To Cursor Pos     *** NOT IMPLEMENTED *** 
# >>>	# DEFAULT UNDO_LAST         [CTRL][Z]           |  ? |  ? |  ? |  ? | Undo Last Operation (Copy/Cut/Paste)       *** NOT IMPLEMENTED *** 
	# DEFAULT INCR_CURS_CTXT    [ENTER]  Key        | 13 |  - |  - |  - | Increse  Cursor Context/Begin Editing      curs_ctxt_incr() 
	# DEFAULT DECR_CURS_CTXT    [ESCAPE] Key        | 27 |  - |  - |  - | Decrease Cursor Context/Stop  Editing      curs_ctxt_decr() 
	# DEFAULT SCROLL_UP_1LN     [k] Key (Low Case)  |107 |  - |  - |  - | Scroll Up x 1 Line                         scroll_down_1x_line() 
	# DEFAULT SCROLL_UP_1PG     [K] Key (Upp Case)  | 75 |  - |  - |  - | Scroll Up x 1 Page                         scroll_down_1x_page() 
	# DEFAULT SCROLL_UP_1PG     [PgUp] Key          |  0 | 33 | 73 |288 | Scroll Up x 1 Page                         scroll_down_1x_page() 
	# DEFAULT SCROLL_UP_1PG     [PgUp] Key          |  0 | 33 | 73 |256 | Scroll Up x 1 Page                         scroll_down_1x_page() 
	# DEFAULT SCROLL_DOWN_1LN   [j] Key (Low Case)  |106 |  - |  - |  - | Scroll Down  x 1 Line                      scroll_down_1x_line() 
	# DEFAULT SCROLL_DOWN_1PG   [J] Key (Upp Case)  | 74 |  - |  - |  - | Scroll Down x 1 Page                       scroll_down_1x_page() 
	# DEFAULT SCROLL_DOWN_1PG   [PgDn]  Key         |  0 | 34 | 81 |288 | Scroll Down x 1 Page                       scroll_down_1x_page() 
	# DEFAULT SCROLL_DOWN_1PG   [PgDn]  Key         |  0 | 34 | 81 |256 | Scroll Down x 1 Page                       scroll_down_1x_page() 
	# DEFAULT SCROLL_DOWN_1PG   [SPACE] Key         | 32 |  - |  - |  - | Scroll Down x 1 Page                       scroll_down_1x_page() 
	# DEFAULT MOVE_CURS_BACK    [SHIFT][TAB] Keys   |  9 | 15 |  9 | 48 | Move Cursor BACK    x 1 Word/Char          curs_mv_back() 
	# DEFAULT MOVE_CURS_FORWARD [TAB] Key           |  9 | 15 |  9 | 32 | Move Cursor FORWARD x 1 Word/Char          curs_mv_fwd() 
	# DEFAULT MOVE_CURS_FORWARD [TAB] Key           |  9 | 15 |  9 |  0 | Move Cursor FORWARD x 1 Word/Char          curs_mv_fwd() 
	# DEFAULT MOVE_CURS_UP      [UP] Arrow Key      |  0 | 38 | 72 |288 | Move Cursor UP   x 1 Line                  curs_mv_up() 
	# DEFAULT MOVE_CURS_UP      [UP] Arrow Key      |  0 | 38 | 72 |256 | Move Cursor UP   x 1 Line                  curs_mv_up() 
	# DEFAULT MOVE_CURS_DOWN    [DOWN] Arrow Key    |  0 | 40 | 80 |288 | Move Cursor DOWN x 1 Line                  curs_mv_down() 
	# DEFAULT MOVE_CURS_DOWN    [DOWN] Arrow Key    |  0 | 40 | 80 |256 | Move Cursor DOWN x 1 Line                  curs_mv_down() 
	# DEFAULT MOVE_CURS_LEFT    [h] Key (Low Case)  |104 |  - |  - |  - | Move Cursor LEFT  x 1 Word/Char            curs_mv_left() 
	# DEFAULT MOVE_CURS_LEFT    [LEFT] Arrow Key    |  0 | 37 | 75 |288 | Move Cursor LEFT  x 1 Word/Char            curs_mv_left() 
	# DEFAULT MOVE_CURS_LEFT    [LEFT] Arrow Key    |  0 | 37 | 75 |256 | Move Cursor LEFT  x 1 Word/Char            curs_mv_left() 
	# DEFAULT MOVE_CURS_RIGHT   [l] Key (Low Case)  |108 |  - |  - |  - | Move Cursor RIGHT x 1 Word/Char            curs_mv_right() 
	# DEFAULT MOVE_CURS_RIGHT   [RIGHT] Arrow Key   |  0 | 39 | 77 |288 | Move Cursor RIGHT x 1 Word/Char            curs_mv_right() 
	# DEFAULT MOVE_CURS_RIGHT   [RIGHT] Arrow Key   |  0 | 39 | 77 |256 | Move Cursor RIGHT x 1 Word/Char            curs_mv_right() 
	# DEFAULT L_MOUSE_BUTTON    LEFT  Mouse Button  |  ? |  ? |  ? |  ? | Highlight line/word/byte at mouse pointer  lmouse() 
	# DEFAULT R_MOUSE_BUTTON    RIGHT Mouse Button  |  ? |  ? |  ? |  ? | ???                                        rmouse() 
	# DEFAULT DEBUG_OFF         [d] Key (Low Case)  | // | // | // | // | Disable display of debugging information   debug_on()
	# DEFAULT DEBUG_ON          [D] Key (Upp Case)  | // | // | // | // | Enable  display of debugging information   debug_off()
	# DEFAULT MOVE_BEG          [SHIFT][6] Keys: ^  | // | // | // | // | Move cursor to first byte                  move_to_beginning() 
	# DEFAULT MOVE_END          [SHIFT][4] Keys: $  | // | // | // | // | Move cursor to last byte                   move_to_end() 
	# DEFAULT VSTRETCH          [CTRL][UP] Arrow key|  0 | 38 | 72 | 264| Stretch the editor display verically       vstretch()
	# DEFAULT VCOMPRESS         [CTRL][DN] Arrow key|  0 | 40 | 80 | 264| Compress the editor display vertcially     vcompress()

	foreach my $evt_reg 
	( [ 'DEFAULT', 'QUIT',              sub { $self->quit(); } ],
	  [ 'DEFAULT', 'CONSCURS_INVIS',    sub { $objConsole->w32cons_cursor_invisible(); } ],
	  [ 'DEFAULT', 'CONSCURS_VIS',      sub { $objConsole->w32cons_cursor_visible(); } ],
	  [ 'DEFAULT', 'INSERT_MODE',       sub { $self->insert_mode(); } ],
	  [ 'DEFAULT', 'WRITE_DISK',        sub { return (0); } ],
	  [ 'DEFAULT', 'SEARCH_MODE',       sub { $self->search_mode(); } ],
	  [ 'DEFAULT', 'JUMP_TO_LINE',      sub { return (0); } ],
	  [ 'DEFAULT', 'COPY_REGION',       sub { return (0); } ],
	  [ 'DEFAULT', 'CUT_REGION',        sub { return (0); } ],
	  [ 'DEFAULT', 'PASTE_BUFFER',      sub { return (0); } ],
	  [ 'DEFAULT', 'UNDO_LAST',         sub { return (0); } ],
	  [ 'DEFAULT', 'SCROLL_UP_1LN',     sub { $objEditor->scroll_up_1x_line(); } ],
	  [ 'DEFAULT', 'SCROLL_UP_1PG',     sub { $objEditor->scroll_up_1x_page(); } ],
	  [ 'DEFAULT', 'SCROLL_DOWN_1LN',   sub { $objEditor->scroll_down_1x_line(); } ],
	  [ 'DEFAULT', 'SCROLL_DOWN_1PG',   sub { $objEditor->scroll_down_1x_page(); } ],
	  [ 'DEFAULT', 'INCR_CURS_CTXT',    sub { $objCursor->curs_ctxt_incr(); } ],
	  [ 'DEFAULT', 'DECR_CURS_CTXT',    sub { $objCursor->curs_ctxt_decr(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_FORWARD', sub { $objCursor->curs_mv_fwd(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_BACK',    sub { $objCursor->curs_mv_back(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_UP',      sub { $objCursor->curs_mv_up(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_DOWN',    sub { $objCursor->curs_mv_down(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_LEFT',    sub { $objCursor->curs_mv_left(); } ],
	  [ 'DEFAULT', 'MOVE_CURS_RIGHT',   sub { $objCursor->curs_mv_right(); } ],
	  [ 'DEFAULT', 'L_MOUSE_BUTTON',    sub { $objConsole->lmouse(); } ],
	  [ 'DEFAULT', 'R_MOUSE_BUTTON',    sub { $objConsole->rmouse(); } ],
	  [ 'DEFAULT', 'DEBUG_OFF',         sub { $self->debug_off(); } ],
	  [ 'DEFAULT', 'DEBUG_ON',          sub { $self->debug_on(); } ],
	  [ 'DEFAULT', 'MOVE_BEG',          sub { $self->move_to_beginning(); } ],
	  [ 'DEFAULT', 'MOVE_END',          sub { $self->move_to_end(); } ],
	  [ 'DEFAULT', 'VSTRETCH',          sub { $self->vstretch(); } ],
	  [ 'DEFAULT', 'VCOMPRESS',         sub { $self->vcompress(); } ],

	# _____________________________________________________________________________________________________
	# EVENT DRIVEN FUNCTION TABLE: TABLE OF WRAPPER FUNCTIONS PROVIDING UNIFORM NAMES/API TO EVENT HANDLERS
	#   'INSERT' Context Functions:
	# _______________   ___________________ _____________________ ____________________                       _________________ 
	# FUNCTION NAME     KEYBOARD MAPPING    |CHAR|VKCD|VSCD|CTRL| FUNCTION DESCRIPTION                       INTERNAL FUNCTION 
	# _______________   ___________________ |____|____|____|____| ____________________                       _________________ 
	# INSERT_ESCAPE     [ESCAPE] Key        | 27 |  - |  - |  - | Decrease Cursor Context/Stop  Editing      insert_escape() 
	# INSERT_BACKSPACE  [BACKSPACE] Key     |    |    |    |    | Delete Character Left Of Cursor            insert_backspace()
	# INSERT_CHAR       <ANY KEY>           |    |    |    |    | Insert Character At Cursor                 insert_char()
	# INSERT_ENTER      [ENTER] Key         |    |    |    |    | Finish Inserting Character(s)              insert_enter()
	# INSERT_L_ARROW    [LEFT ARROW] Key    |    |    |    |    | Move Cursor To The Left One Character      insert_l_arrow()
	# INSERT_R_ARROW    [RIGHT ARROW] Key   |    |    |    |    | Move Cursor To The Right One Character     insert_r_arrow()

	  [ 'INSERT', 'INSERT_BACKSPACEINSERT', sub { $self->insert_backspace(); } ],
	  [ 'INSERT', 'INSERT_CHAR',            sub { $self->insert_char(); } ],
	  [ 'INSERT', 'INSERT_ENTER',           sub { $self->insert_enter(); } ],
	  [ 'INSERT', 'INSERT_ESCAPE',          sub { $self->insert_escape(); } ],
	  [ 'INSERT', 'INSERT_L_ARROW',         sub { $self->insert_l_arrow(); } ],
	  [ 'INSERT', 'INSERT_R_ARROW',         sub { $self->insert_r_arrow(); } ],

	# _____________________________________________________________________________________________________
	# EVENT DRIVEN FUNCTION TABLE: TABLE OF WRAPPER FUNCTIONS PROVIDING UNIFORM NAMES/API TO EVENT HANDLERS
	#   'SEARCH' Context Functions
	# _______________   ___________________ _____________________ ____________________                       _________________ 
	# FUNCTION NAME     KEYBOARD MAPPING    |CHAR|VKCD|VSCD|CTRL| FUNCTION DESCRIPTION                       INTERNAL FUNCTION 
	# _______________   ___________________ |____|____|____|____| ____________________                       _________________ 
	# SEARCH_BACKSPACE  [BACKSPACE] Key     | 27 |  - |  - |  - | ...                                        search_backspace()
	# SEARCH_CHAR       <ANY KEY>           | 27 |  - |  - |  - | ...                                        search_char()
	# SEARCH_ENTER      [ENTER] Key         | 27 |  - |  - |  - | ...                                        search_enter()
	# SEARCH_ESCAPE     [ESCAPE] Key        | 27 |  - |  - |  - | Decrease Cursor Context/Stop  Editing      search_escape() 
	# SEARCH_L_ARROW    [LEFT ARROW] Key    | 27 |  - |  - |  - | ...                                        search_l_arrow()
	# SEARCH_R_ARROW    [RIGHT ARROW] Key   | 27 |  - |  - |  - | ...                                        search_r_arrow()

	  [ 'SEARCH', 'SEARCH_BACKSPACE', sub { $self->search_backspace(); } ],
	  [ 'SEARCH', 'SEARCH_CHAR',      sub { $self->search_char(); } ],
	  [ 'SEARCH', 'SEARCH_ENTER',     sub { $self->search_enter(); } ],
	  [ 'SEARCH', 'SEARCH_ESCAPE',    sub { $self->search_escape(); } ],
	  [ 'SEARCH', 'SEARCH_L_ARROW',   sub { $self->search_l_arrow(); } ],
	  [ 'SEARCH', 'SEARCH_R_ARROW',   sub { $self->search_r_arrow(); } ] ) {

		# print $evt_reg->[0] . "\t" . $evt_reg->[1] . "\t" . $evt_reg->[2] . "\n";

		$objEventLoop->register_callback ({ 'ctxt' => $evt_reg->[0], 'evt_nm' => $evt_reg->[1], 'evt_cb' => $evt_reg->[2] });

	}

	return (1);
}

# Functions: 'DEFAULT' context event handlers.
#
#   ____			__________	___________
#   NAME			Event Name	DESCRIPTION
#   ____			__________	___________
#   debug_off()			DEBUG_OFF	Disable display of debugging information.
#   debug_on()			DEBUG_ON	Enable  display of debugging information.
#   insert_mode()		INSERT_MODE	Switch to 'INSERT' context.
#   search_mode()		SEARCH_MODE	Switch to 'SEARCH' context.
#   move_to_beginning()		MOVE_BEG	Move to first byte of file.
#   move_to_end()		MOVE_END	Move to last  byte of file.
#   quit()			QUIT		Break out of event_loop(), clean up, exit().
#   vstretch()			VSTRETCH	Stretch the editor display vertically.
#   vcompress()                 VCOMPRESS       Compress the editor display vertically.

sub debug_off {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};

	foreach my $d_element_nm 
	  ('dbg_mouse_evt', 
	   'dbg_keybd_evt', 
	   'dbg_unmatched_evt', 
	   'dbg_curs', 
	   'dbg_display', 
	   'dbg_count', 
	   'dbg_console', 
	   'errmsg_queue') {

		$objDisplay->{'d_elements'}->{$d_element_nm}->{'enabled'} = 0;
	}

	return (1);
}

sub debug_on {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};

	foreach my $d_element_nm 
	  ('dbg_mouse_evt', 
	   'dbg_keybd_evt', 
	   'dbg_unmatched_evt', 
	   'dbg_curs', 
	   'dbg_display', 
	   'dbg_count', 
	   'dbg_console', 
	   'errmsg_queue') {

		$objDisplay->{'d_elements'}->{$d_element_nm}->{'enabled'} = 1;
	}

	return (1);
}

sub insert_mode {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};     # Used.
	my $objCursor    = $self->{'obj'}->{'cursor'};      # Used.
	my $objDisplay   = $self->{'obj'}->{'display'};     # Used.
	my $objEditor    = $self->{'obj'}->{'editor'};      # Used.
	my $objEventLoop = $self->{'obj'}->{'eventloop'};   # Used.

	# Switch context to 'INSERT'.

	$objEventLoop->{'CTXT'} = 'INSERT';

	# Change cursor context to 3 (insert mode).

	if (! ($objCursor->{'curs_ctxt'} == 3)) 
		{ $objCursor->{'curs_ctxt'} = 3; }

	# Define variables used to manage the insert user interface.

	if (! exists  $self->{'insert_str'} || 
	    ! defined $self->{'insert_str'}) {

		$self->{'insert_str'} = '';
	}

	if (! exists  $self->{'insert_pos'} || 
	    ! defined $self->{'insert_pos'} || 
	           ! ($self->{'insert_pos'} =~ /^\d+?$/)) {

		$self->{'insert_pos'} = 0;
	}

	# Move Win32 console cursor to insert position.
	# Make Win32 console cursor visible.

	my ($xpos, $ypos) = 
	  $objCursor->dsp_coord 
	    ({ 'curs_pos' => $objCursor->{'curs_pos'}, 
	       'dsp_pos'  => $objEditor->{'dsp_pos'}, 
	       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
	       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

	$objConsole->w32cons_cursor_move 
	  ({ 'xpos' => ($xpos + $objDisplay->{'dsp_xpad'}), 
	     'ypos' => ($ypos + $objDisplay->{'dsp_ypad'}) });

	$objConsole->w32cons_cursor_visible();

	return (1);
}

sub search_mode {

	my $self = shift;

	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objConsole   = $self->{'obj'}->{'console'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch context to 'SEARCH'.

	$objEventLoop->{'CTXT'} = 'SEARCH';

	# Draw search box over the top of the editor display.

	$objDisplay->{'d_elements'}->{'search_box'}->{'enabled'} = 1;

	# Define variables used to manage the search user interface.

	if (! exists  $self->{'search_str'} || 
	    ! defined $self->{'search_str'}) {

		$self->{'search_str'} = '';
	}

	if (! exists  $self->{'search_pos'} || 
	    ! defined $self->{'search_pos'} || 
	           ! ($self->{'search_pos'} =~ /^\d+?$/)) {

		$self->{'search_pos'} = 0;
	}

	# Store the value of 'curs_ctxt' so that it can be restored.
	# Set cursor context to 3 (make it disappear while search box displayed).

	$self->{'curs_ctxt_prev'} = $objCursor->{'curs_ctxt'};
	$objCursor->{'curs_ctxt'} = 3;

	# Move Win32 console cursor to beginning of text string position (within search box).
	# Make Win32 console cursor visible.

	$objConsole->w32cons_cursor_move 
	  ({ 'xpos' => ($objDisplay->{'d_elements'}->{'search_box'}->{'e_xpos'} + 4), 
	     'ypos' => ($objDisplay->{'d_elements'}->{'search_box'}->{'e_ypos'} + 3) });

	$objConsole->w32cons_cursor_visible();

	return (1);
}

sub move_to_beginning {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};

	$objEditor->{'dsp_pos'} = 0;
	$objCursor->{'curs_pos'} = 0;

	return (1);
}

sub move_to_end {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};
	my $objFile   = $self->{'obj'}->{'file'};

	if ($objFile->file_len() > 
	      (($objEditor->{'sz_line'} * $objEditor->{'sz_column'}) + $objEditor->{'sz_line'})) {
	
		$objEditor->{'dsp_pos'} = 
		  ($objCursor->align_line_boundary 
		     ({ 'pos' => $objFile->file_len() }) - 
		   (($objEditor->{'sz_line'} * $objEditor->{'sz_column'}) - 
		       $objEditor->{'sz_line'}));
	}
	else {
	
		$objEditor->{'dsp_pos'} = 0;
	}

	$objCursor->{'curs_pos'} = ($objFile->file_len() - 1);
	$objCursor->{'curs_ctxt'} = 2;

	return (1);
}

sub quit {

	my $self = shift;

	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	$objEventLoop->{'FLAG_QUIT'} = 1;

	return (1);
}

sub vstretch {

	my $self = shift;

	my $objDisplay   = $self->{'obj'}->{'display'};     # Used.
	my $objEditor    = $self->{'obj'}->{'editor'};      # Used.
	my $objEventLoop = $self->{'obj'}->{'eventloop'};   # Used.
	my $objFile      = $self->{'obj'}->{'file'};        # Used.

	if ($objEditor->{'sz_column'} <= 
	    ($objDisplay->{'d_height'} - 
	     ($objDisplay->{'dsp_ypad'} + 
	      $objDisplay->{'d_elements'}->{'column_titles'}->{'e_height'} + 
	      $objDisplay->{'d_elements'}->{'column_titles'}->{'vpad'} + 
	      $objDisplay->{'d_elements'}->{'sep'}->{'e_height'} + 
	      $objDisplay->{'d_elements'}->{'sep'}->{'vpad'} + 
	      $objDisplay->{'d_elements'}->{'errmsg_queue'}->{'e_height'} + 
	      $objDisplay->{'d_elements'}->{'errmsg_queue'}->{'vpad'}))) {

		$objEditor->set_sz_column 
		  ({ 'sz_column' => ($objEditor->{'sz_column'} + 1) });

		if ($objEditor->{'dsp_pos'} > 
		      ($objFile->file_len() - 
			 (($objEditor->{'sz_column'} * $objEditor->{'sz_line'}) - 
		            $objEditor->{'sz_line'}))) {

			$objEditor->set_dsp_pos 
			  ({ 'dsp_pos' => ($objEditor->{'dsp_pos'} - 
			                   $objEditor->{'sz_line'}) });
		}

		$objEventLoop->adjust_display();
	}

	return (1);
}

sub vcompress {

	my $self = shift;

	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	if ($objEditor->{'sz_column'} > 1) {

		$objEditor->set_sz_column 
		  ({ 'sz_column' => ($objEditor->{'sz_column'} - 1) });
	}

	while ($objCursor->{'curs_pos'} >= 
	       ($objEditor->{'dsp_pos'} + 
	        ($objEditor->{'sz_column'} * $objEditor->{'sz_line'}))) {

		$objCursor->curs_mv_up();
	}

	$objEventLoop->adjust_display();

	return (1);
}


# Functions: 'INSERT' context event handlers.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   insert_backspace()		Delete character to the left of the cursor.
#   insert_char()		Insert character at the cursor position.
#   insert_enter()		Begin search using the search string specified by user.
#   insert_escape()		Cancel search operation, switch context to 'DEFAULT'.
#   insert_l_arrow()		Move the cursor to the left within the text string inside the search box.
#   insert_r_arrow()		Move the cursor to the right within the text string inside the search box.

sub insert_backspace {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'insert_str'} && 
	    defined $self->{'insert_str'} && 
	          ! $self->{'insert_str'} eq '') {

		$self->{'insert_str'} =~ s/.$//;   # Remove last character from string.
		$self->{'insert_pos'}--;

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub insert_char {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	my $char = chr ($objEventLoop->{'evt'}->[5]);

	# If inserting in hex mode, make sure character is: 1 - 9 or A - F.

	if (! ($char =~ /^[1234567890abcdefABCDEF]$/)) {

		$objDebug->errmsg ("Bad value for char: '" . $char . "'.");
		return (undef);
	}

	# If inserting in hex mode, check to see if the first character 
	# (of a two character string) was already entered.

	if (! exists  $self->{'first_hex_char'} || 
	    ! defined $self->{'first_hex_char'} || 
	           ! ($self->{'first_hex_char'} =~ /^[1234567890abcdefABCDEF]$/)) {

		$self->{'first_hex_char'} = $char;

		my ($xpos, $ypos) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $objCursor->{'curs_pos'}, 
		       'dsp_pos'  => $objEditor->{'dsp_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		$xpos++;
		$objConsole->w32cons_cursor_move 
		  ({ 'xpos' => ($xpos + $objDisplay->{'dsp_xpad'}), 
		     'ypos' => ($ypos + $objDisplay->{'dsp_ypad'}) });
	}
	else {

		my $ord  = hex ($self->{'first_hex_char'} . $char);
		my $byte = chr ($ord);

		$self->{'first_hex_char'} = undef;

		# Insert character into place in file (at cursor position).

		my $rv = 
		  $objFile->insert_str 
		    ({ 'pos' => $objCursor->{'curs_pos'}, 
		       'str' => $byte });

		if (defined $rv && 
			    $rv == 1) 
		     { $objDebug->errmsg ("Call to insert_str() returned w/ success."); } 
		else { $objDebug->errmsg ("Call to insert_str() returned w/ failure.");
		       return (undef); }

		# Update editor cursor position.

		$objCursor->{'curs_pos'}++;

		# Update Win32 Console cursor position.

		my ($xpos, $ypos) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $objCursor->{'curs_pos'}, 
		       'dsp_pos'  => $objEditor->{'dsp_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		$objConsole->w32cons_cursor_move 
		  ({ 'xpos' => ($xpos + $objDisplay->{'dsp_xpad'}), 
		     'ypos' => ($ypos + $objDisplay->{'dsp_ypad'}) });
	}

	return (1);
}

sub insert_enter {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch context to 'DEFAULT'.

	$objEventLoop->{'CTXT'} = 'DEFAULT';

	# Change cursor context to 2 (byte mode).

	if (! ($objCursor->{'curs_ctxt'} == 2)) 
		{ $objCursor->{'curs_ctxt'} = 2; }

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	return (1);
}

sub insert_escape {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch context to 'DEFAULT'.

	$objEventLoop->{'CTXT'} = 'DEFAULT';

	# Change cursor context to 2 (byte mode).

	if (! ($objCursor->{'curs_ctxt'} == 2)) 
		{ $objCursor->{'curs_ctxt'} = 2; }

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	return (1);
}

sub insert_l_arrow {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# ...

	return (1);
}

sub insert_r_arrow {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# ...

	return (1);
}

# Functions: 'SEARCH' context event handlers.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   search_backspace()
#   search_char()
#   search_enter()
#   search_escape()
#   search_l_arrow()
#   search_r_arrow()

sub search_backspace {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '') && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	           ($self->{'search_pos'} > 0)) {

		if ($self->{'search_pos'} < length ($self->{'search_str'})) {

			substr $self->{'search_str'}, ($self->{'search_pos'} - 1), 1, '';
		}
		else {

			$self->{'search_str'} =~ s/.$//;   # Remove last character from string.
		}

		$self->{'search_pos'}--;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub search_char {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $char = chr ($objEventLoop->{'evt'}->[5]);

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '') && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	           ($self->{'search_pos'} =~ /^\d+?$/) && 
	           ($self->{'search_pos'} < (length ($self->{'search_str'})))) {

		substr $self->{'search_str'}, $self->{'search_pos'}, 0, $char;
	}
	else {

		$self->{'search_str'} .= $char;
	}

	$self->{'search_pos'}++;

	# Update position of Win32 console cursor.

	$objConsole->w32cons_cursor_move 
	  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} + 1), 
	     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });

	return (1);
}

sub search_enter {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '')) {

		# index STR, SUBSTR, POSITION
		# index STR, SUBSTR
		#   The index function searches for one string within another, but
		#   without the wildcard-like behavior of a full regular-expression
		#   pattern match. It returns the position of the first occurrence
		#   of SUBSTR in STR at or after POSITION. If POSITION is omitted,
		#   starts searching from the beginning of the string. POSITION
		#   before the beginning of the string or after its end is treated
		#   as if it were the beginning or the end, respectively. POSITION
		#   and the return value are based at zero. If the substring is not
		#   found, "index" returns -1.

		$objDebug->errmsg 
		  ("Call to function file_bytes() returned w/ '" . 
		   scalar (@{ $objFile->file_bytes 
		                ({ 'ofs' => $objCursor->{'curs_pos'}, 
		                   'len' => (($objFile->file_len() - 1) - $objCursor->{'curs_pos'}) }) }) . "' bytes.");

		# Search for user specified string within file.

		my $rv = 
		  index ((join '', @{ $objFile->file_bytes 
		                        ({ 'ofs' => $objCursor->{'curs_pos'}, 
		                           'len' => (($objFile->file_len() - 1) - $objCursor->{'curs_pos'}) }) }), 
		         $self->{'search_str'}, 
		         1);

		if ($rv > 0) {

			# Move cursor to the beginning position where string was matched.

			$objCursor->{'curs_pos'} = ($objCursor->{'curs_pos'} + $rv);

			# Set cursor context to '2' (byte context).

			$objCursor->{'curs_ctxt'} = 2;

			# If cursor is positioned beyond the editor display, 
			# move the editor display so that cursor is in view.

			while ($objEditor->{'dsp_pos'} < 
			         ($objCursor->{'curs_pos'} - 
			            (($objEditor->{'sz_line'} * $objEditor->{'sz_column'}) -
			                length ($self->{'search_str'})))) {

				$objEditor->{'dsp_pos'} += $objEditor->{'sz_line'};
			}
		}
		else {

			# Restore cursor context to previous value (or byte mode).

			if (exists  $self->{'curs_ctxt_prev'} && 
			    defined $self->{'curs_ctxt_prev'} && 
				   ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

				$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
			}
			elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

				$objCursor->{'curs_ctxt'} = 2;
			}
		}
	}
	else {

		# Restore cursor context to previous value (or byte mode).

		if (exists  $self->{'curs_ctxt_prev'} && 
		    defined $self->{'curs_ctxt_prev'} && 
			   ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

			$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
		}
		elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

			$objCursor->{'curs_ctxt'} = 2;
		}
	}

	# Switch context to 'DEFAULT'.

	$objEventLoop->{'CTXT'} = 'DEFAULT';

	# Disable search box display.

	$objDisplay->{'d_elements'}->{'search_box'}->{'enabled'} = 0;

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	# Erase variables used to manage search user interface.

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;

	return (1);
}

sub search_escape {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch context to 'DEFAULT'.

	$objEventLoop->{'CTXT'} = 'DEFAULT';

	# Restore cursor context to previous value (or 2: byte mode).

	if (exists  $self->{'curs_ctxt_prev'} && 
	    defined $self->{'curs_ctxt_prev'} && 
	           ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

		$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
	}
	elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

		$objCursor->{'curs_ctxt'} = 2;
	}

	# Disable search box display.

	$objDisplay->{'d_elements'}->{'search_box'}->{'enabled'} = 0;

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	# Erase variables used to manage search user interface.

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;

	return (1);
}

sub search_l_arrow {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '' && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	            $self->{'search_pos'} =~ /^\d+?$/ && 
	            $self->{'search_pos'} > 0) {

		$self->{'search_pos'}--;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub search_r_arrow {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '' && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	            $self->{'search_pos'} =~ /^\d+?$/ && 
	            $self->{'search_pos'} < (length ($self->{'search_str'}))) {

		$self->{'search_pos'}++;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} + 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

# Functions: Display element routines.
#
#   ____		___________
#   NAME		DESCRIPTION
#   ____		___________
#   search_box()	Return a "search box" formatted for display console.

sub search_box {

	my $self = shift;

	# Display box 140 chars wide x 12 chars tall.

	my @search_box = 
	  ( '_' x 140, 
	    '|' . (' ' x 138) . '|', 
	    '_' x 140 );

	# If search string already defined, add it to the search box display.

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '') {

		my $replaced_str = 
		  substr $search_box[1], 
		         2, 
		         length ($self->{'search_str'}), 
		         $self->{'search_str'};
	}

	return (\@search_box);
}


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

=head2 debug_off
Method debug_off()...
= cut

=head2 debug_on
Method debug_on()...
= cut

=head2 init
Method init()...
= cut

=head2 insert_backspace
Method insert_backspace()...
= cut

=head2 insert_char
Method insert_char()...
= cut

=head2 insert_enter
Method insert_enter()...
= cut

=head2 insert_escape
Method insert_escape()...
= cut

=head2 insert_l_arrow
Method insert_l_arrow()...
= cut

=head2 insert_mode
Method insert_mode()...
= cut

=head2 insert_r_arrow
Method insert_r_arrow()...
= cut

=head2 move_to_beginning
Method move_to_beginning()...
= cut

=head2 move_to_end
Method move_to_end()...
= cut

=head2 quit
Method quit()...
= cut

=head2 register_event_callbacks
Method register_event_callbacks()...
= cut

=head2 search_backspace
Method search_backspace()...
= cut

=head2 search_box
Method search_box()...
= cut

=head2 search_char
Method search_char()...
= cut

=head2 search_enter
Method search_enter()...
= cut

=head2 search_escape
Method search_escape()...
= cut

=head2 search_l_arrow
Method search_l_arrow()...
= cut

=head2 search_mode
Method search_mode()...
= cut

=head2 search_r_arrow
Method search_r_arrow()...
= cut

=head2 vstretch
Method vstretch()...
= cut

=head2 vcompress
Method vcompress()...
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

