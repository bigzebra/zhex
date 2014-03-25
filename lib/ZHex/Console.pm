#!/usr/bin/perl

package ZHex::Console;

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

use Win32::Console 
 qw(BACKGROUND_BLUE 
    BACKGROUND_GREEN 
    BACKGROUND_INTENSITY 
    BACKGROUND_RED 
    CAPSLOCK_ON 
    CONSOLE_TEXTMODE_BUFFER 
    CTRL_BREAK_EVENT 
    CTRL_C_EVENT 
    ENABLE_ECHO_INPUT 
    ENABLE_LINE_INPUT 
    ENABLE_MOUSE_INPUT 
    ENABLE_PROCESSED_INPUT 
    ENABLE_PROCESSED_OUTPUT 
    ENABLE_WINDOW_INPUT 
    ENABLE_WRAP_AT_EOL_OUTPUT 
    ENHANCED_KEY 
    FILE_SHARE_READ 
    FILE_SHARE_WRITE 
    FOREGROUND_BLUE 
    FOREGROUND_GREEN 
    FOREGROUND_INTENSITY 
    FOREGROUND_RED 
    GENERIC_READ 
    GENERIC_WRITE 
    LEFT_ALT_PRESSED 
    LEFT_CTRL_PRESSED 
    NUMLOCK_ON 
    RIGHT_ALT_PRESSED 
    RIGHT_CTRL_PRESSED 
    SCROLLLOCK_ON 
    SHIFT_PRESSED 
    STD_INPUT_HANDLE 
    STD_OUTPUT_HANDLE 
    STD_ERROR_HANDLE 
    @CONSOLE_COLORS 
    $ATTR_NORMAL 
    $ATTR_INVERSE 
    $FG_BLACK 
    $FG_BROWN 
    $FG_CYAN 
    $FG_GRAY 
    $FG_BLUE 
    $FG_GREEN 
    $FG_LIGHTBLUE 
    $FG_LIGHTCYAN 
    $FG_LIGHTGRAY 
    $FG_LIGHTGREEN 
    $FG_LIGHTMAGENTA 
    $FG_LIGHTRED 
    $FG_MAGENTA 
    $FG_RED 
    $FG_WHITE 
    $FG_YELLOW 
    $BG_BLACK 
    $BG_BLUE 
    $BG_BROWN 
    $BG_CYAN 
    $BG_GRAY 
    $BG_GREEN 
    $BG_LIGHTBLUE 
    $BG_LIGHTCYAN 
    $BG_LIGHTGRAY 
    $BG_LIGHTGREEN 
    $BG_LIGHTMAGENTA 
    $BG_LIGHTRED 
    $BG_MAGENTA 
    $BG_RED 
    $BG_WHITE 
    $BG_YELLOW);

# Functions: Start-up/initialization.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Global variable declarations

sub init {

	my $self = shift;

	# References to Win32::Console objects stored in keys.

	$self->{'CONS'}    = '';   # Console handle objects ala Win32::Console 
	$self->{'CONS_IN'} = '';   # Console handle objects ala Win32::Console 

	# Various Win32::Console attributes and settings.

	$self->{'w32cons_attr_orig'}      = '';   # Original console attributes STDOUT [used by function Write()].
	$self->{'w32cons_in_attr_orig'}   = '';   # Original console attributes STDIN  [used by function Write()].
	$self->{'w32cons_title_orig'}     = '';   # Original display title
	$self->{'w32cons_title_ZHex'} = '';   # Console window title (displayed in title bar).
	$self->{'w32cons_codep_in'}       = '';   # ...
	$self->{'w32cons_codep_out'}      = '';   # ...
	$self->{'w32cons_buf_cols'}       = '';   # (X/Col) Current size console buffer.
	$self->{'w32cons_buf_rows'}       = '';   # (Y/Row) Current size console buffer.
	$self->{'w32cons_buf_cols_max'}   = '';   # (X/Col) Max number columns (console window?/buffer?) given size of: buffer/font/screen.
	$self->{'w32cons_buf_rows_max'}   = '';   # (Y/Row) Max number rows    (console window>/buffer?) given size of: buffer/font/screen.
	$self->{'w32cons_curs_xpos'}      = '';   # (X/Col) Current position cursor (console window).
	$self->{'w32cons_curs_ypos'}      = '';   # (Y/Row) Current position cursor (console window).
	$self->{'w32cons_first_col'}      = '';   # (X/Col) Upper-left-most position (console window).
	$self->{'w32cons_top_row'}        = '';   # (Y/Row) Upper-left-most position (console window).
	$self->{'w32cons_last_col'}       = '';   # (X/Col) Lower-right-most position (console window).
	$self->{'w32cons_bottom_row'}     = '';   # (Y/Row) Lower-right-most position (console window).
	$self->{'w32cons_buf_cols_orig'}  = '';   # ...
	$self->{'w32cons_buf_rows_orig'}  = '';   # ...
	$self->{'w32cons_mode_orig'}      = '';   # ...
	$self->{'w32cons_in_mode_orig'}   = '';   # ...

	# Foreground colors.

	$self->{'FG_BLACK'}        = $FG_BLACK;
	$self->{'FG_BROWN'}        = $FG_BROWN;
	$self->{'FG_CYAN'}         = $FG_CYAN;
	$self->{'FG_GRAY'}         = $FG_GRAY;
	$self->{'FG_BLUE'}         = $FG_BLUE;
	$self->{'FG_GREEN'}        = $FG_GREEN;
	$self->{'FG_LIGHTBLUE'}    = $FG_LIGHTBLUE;
	$self->{'FG_LIGHTCYAN'}    = $FG_LIGHTCYAN;
	$self->{'FG_LIGHTGRAY'}    = $FG_LIGHTGRAY;
	$self->{'FG_LIGHTGREEN'}   = $FG_LIGHTGREEN;
	$self->{'FG_LIGHTMAGENTA'} = $FG_LIGHTMAGENTA;
	$self->{'FG_LIGHTRED'}     = $FG_LIGHTRED;
	$self->{'FG_MAGENTA'}      = $FG_MAGENTA;
	$self->{'FG_RED'}          = $FG_RED;
	$self->{'FG_WHITE'}        = $FG_WHITE;
	$self->{'FG_YELLOW'}       = $FG_YELLOW;

	# Background colors.

	$self->{'BG_BLACK'}        = $BG_BLACK;
	$self->{'BG_BLUE'}         = $BG_BLUE;
	$self->{'BG_BROWN'}        = $BG_BROWN;
	$self->{'BG_CYAN'}         = $BG_CYAN;
	$self->{'BG_GRAY'}         = $BG_GRAY;
	$self->{'BG_GREEN'}        = $BG_GREEN;
	$self->{'BG_LIGHTBLUE'}    = $BG_LIGHTBLUE;
	$self->{'BG_LIGHTCYAN'}    = $BG_LIGHTCYAN;
	$self->{'BG_LIGHTGRAY'}    = $BG_LIGHTGRAY;
	$self->{'BG_LIGHTGREEN'}   = $BG_LIGHTGREEN;
	$self->{'BG_LIGHTMAGENTA'} = $BG_LIGHTMAGENTA;
	$self->{'BG_LIGHTRED'}     = $BG_LIGHTRED;
	$self->{'BG_MAGENTA'}      = $BG_MAGENTA;
	$self->{'BG_RED'}          = $BG_RED;
	$self->{'BG_WHITE'}        = $BG_WHITE;
	$self->{'BG_YELLOW'}       = $BG_YELLOW;

	# Foreground intensity (increase color brightness when combined 
	# with foreground color).

	$self->{'FOREGROUND_INTENSITY'} = FOREGROUND_INTENSITY;

	return (1);
}

# Functions: Win32::Console module wrappers.
#
#   _____________		___________						____________________________
#   Function Name		Description						Win32::Console Function Name
#   _____________		___________						____________________________
#   w32cons_init()		Initialize Win32::Console objects.			new(), Attr()
#   w32cons_clear()		Clear display console.					Cls()
#   w32cons_termcap()		Fetch/store console attrs/dimensions/buffer size.	Size(), Info()
#   w32cons_mode_get()		Fetch/store console mode.				Mode()
#   w32cons_mode_set()		Set console mode.					Mode()
#   w32cons_size_set()		Fetch/store console size, set console size.		Size()
#   w32cons_title_get()		Fetch/store console title.				Title()
#   w32cons_title_set()		Set console title.					Title()
#   w32cons_write()		Write to console.					Cursor(), Write()
#   w32cons_cursor_visible()	Set console cursor invisible.				Cursor()
#   w32cons_cursor_invisible()	Set console cursor visible.				Cursor()
#   w32cons_cursor_tleft_dsp()	...							...
#   w32cons_cursor_bleft_dsp()	...							...
#   w32cons_fg_white_bg_black()	Set foreground white, background black.			FillAttr()
#   w32cons_close()		Reset console attributes to original.			Attr()

sub w32cons_init {

	my $self = shift;

	# This function defines keys:
	#
	#   ___				___________ 
	#   KEY				DESCRIPTION 
	#   ___				___________ 
        #   CONS			Console object (STDOUT) created by Win32::Console::new(). 
	#   CONS_IN			Console object (STDIN)  created by Win32::Console::new(). 
	#   w32cons_attr_orig		Original attributes of console (STDOUT) at beginning of program execution. 
	#   w32cons_codep_in		... 
	#   w32cons_codep_out		... 

	if ($self->{'CONS'} = Win32::Console->new (STD_OUTPUT_HANDLE)) 
	     { undef; }
	else { warn "Function new() returned w/ error. ", $!, $^E; }

	if ($self->{'w32cons_attr_orig'} = $self->{'CONS'}->Attr()) 
	     { undef; }
	else { warn "Function Attr() returned w/ error. ", $!, $^E; }

	if ($self->{'CONS_IN'} = Win32::Console->new (STD_INPUT_HANDLE)) 
	     { undef; }
	else { warn "Function new() returned w/ error. ", $!, $^E; }

	$self->{'w32cons_codep_in'}  = Win32::Console::InputCP();
	$self->{'w32cons_codep_out'} = Win32::Console::OutputCP();

	return (1);
}

sub w32cons_clear {

	my $self = shift;

	# Function: Cls() 
	#   Clear the console.

	if (my $rv = $self->{'CONS'}->Cls ($FG_GREEN | $BG_BLACK)) 
	     { undef; }
	else { warn ("Function Cls() returned w/ error. ", $!, $^E); }

	return (1);
}

sub w32cons_termcap {

	my $self = shift;

	# This function defines keys:
	#
	#   ___				___________ 
	#   KEY				DESCRIPTION 
	#   ___				___________ 
	#   w32cons_attr_orig		Original console attributes [used by function Write()]. 
        #   w32cons_buf_cols		(X/Col) Current size console buffer. 
	#   w32cons_buf_rows		(Y/Row) Current size console buffer. 
	#   w32cons_buf_cols_max	(X/Col) Max number columns (console window) given size of: buffer/font/screen. 
	#   w32cons_buf_rows_max	(Y/Row) Max number rows    (console window) given size of: buffer/font/screen. 
	#   w32cons_buf_cols_orig	(X/Col) Original size console buffer. 
	#   w32cons_buf_rows_orig	(Y/Row) Original size console buffer. 
	#   w32cons_curs_xpos		(X/Col) Current position of cursor (console window). 
	#   w32cons_curs_ypos		(Y/Row) Current position of cursor (console window). 
	#   w32cons_first_col		(X/Col) Upper-left-most position (console window). 
	#   w32cons_top_row		(Y/Row) Upper-left-most position (console window). 
	#   w32cons_last_col		(X/Col) Lower-right-most position (console window). 
	#   w32cons_bottom_row		(Y/Row) Lower-right-most position (console window). 

	#   (Ex.1) my ($x, $y) = $CONS->Size();   [Get size] 
	#   (Ex.2) $CONS->Size (80, 25);          [Set size] 

	# Function: Size() 
	#   Get (or set) the console buffer size. 

	if (($self->{'w32cons_buf_cols_orig'}, $self->{'w32cons_buf_rows_orig'}) = $self->{'CONS'}->Size()) 
	     { undef; }
	else { warn ("Function Size() returned w/ error. Unable to determine console size. ", $!, $^E); }

	# Function: Info() 
	#   Return array (11 values) containing console related values including: 
	#     console buffer size, cursor position, current attributes, screen dimensions, and maximum size.

	if (($self->{'w32cons_buf_cols'},        # (X/Col) Current size console buffer.
	     $self->{'w32cons_buf_rows'},        # (Y/Row) Current size console buffer.
	     $self->{'w32cons_curs_xpos'},       # (X/Col) Current position cursor (console window).
	     $self->{'w32cons_curs_ypos'},       # (Y/Row) Current position cursor (console window).
	     $self->{'w32cons_attr_orig'},       # Original console attributes (used by function Write()).
	     $self->{'w32cons_first_col'},       # (X/Col) Left-most  position (console window).
	     $self->{'w32cons_top_row'},         # (Y/Row) Upper-most position (console window).
	     $self->{'w32cons_last_col'},        # (X/Col) Right-most position (console window).
	     $self->{'w32cons_bottom_row'},      # (Y/Row) Lower-most position (console window).
	     $self->{'w32cons_buf_cols_max'},    # (X/Col) Max number columns  (console window) [based upon size of: buffer/font/screen, and terminal settings].
	     $self->{'w32cons_buf_rows_max'})    # (Y/Row) Max number rows     (console window) [based upon size of: buffer/font/screen, and terminal settings].
		= $self->{'CONS'}->Info()) 
	     { undef; }
	else { warn ("Function Info() returned w/ error. Unable to determine dimensions of display console. ", $!, $^E); }

	return (1);
}

sub w32cons_mode_get {

  	my $self = shift;

	# This function defines keys:
	#
	#   ___				___________ 
	#   KEY				DESCRIPTION 
	#   ___				___________ 
        #   w32cons_mode_orig		Console mode settings before program execution ("console" object). 
        #   w32cons_in_mode_orig	Console mode settings before program execution ("input console" object).

	if ($self->{'w32cons_mode_orig'} = $self->{'CONS'}->Mode()) 
	     { undef; }
	else { warn ("Function Mode() returned w/ error. Unable to store original mode settings. ", $!, $^E); }

	if ($self->{'w32cons_in_mode_orig'} = $self->{'CONS_IN'}->Mode()) 
	     { undef; }
	else { warn ("Function Mode() returned w/ error. Unable to store original mode settings. ", $!, $^E); }

	return (1);
}

sub w32cons_mode_set {

  	my $self = shift;

	# "Modes" exported by Win32::Console 
	# __________________________________ 
	#   ENABLE_LINE_INPUT 
	#   ENABLE_ECHO_INPUT 
	#   ENABLE_PROCESSED_INPUT 
	#   ENABLE_WINDOW_INPUT 
	#   ENABLE_MOUSE_INPUT 
	#   ENABLE_PROCESSED_OUTPUT 
	#   ENABLE_WRAP_AT_EOL_OUTPUT 

	if (my $rv = $self->{'CONS_IN'}->Mode (ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT)) 
	     { undef; }
	else { warn ("Function Mode() returned w/ error. Unable to set mode. ", $!, $^E); }

	return (1);
}

# REVIEW THIS FUNCTION FOR CORRECTNESS, IT LOOKS WRONG...

sub w32cons_size_set {

	my $self = shift;

	# Function: Size() 
	#   Get (or set) the console buffer size.

	if (my $rv = $self->{'CONS'}->Size ($self->{'w32cons_buf_cols_max'}, $self->{'w32cons_buf_rows_max'})) 
	     { undef; }
	else { warn ("Function Size() returned w/ error. Unable to determine console size. ", $!, $^E); }

	return (1);
}

sub w32cons_title_get {

	my $self = shift;

	# This function defines keys:
	#
	#   KEY                   DESCRIPTION 
	#   ___                   ___________ 
        #   w32cons_title_orig    Original title of console window (before program execution). 

	# Function: Title() 
	#   Get (or set) the title of the console window. 

	if ($self->{'w32cons_title_orig'} = $self->{'CONS'}->Title()) 
	     { undef; }
	else { warn ("Function Title() returned w/ failure. Unable to retreive string w/ console window title. ", $!, $^E); }

	return (1);
}

sub w32cons_title_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to w32cons_title_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'w32cons_title'} || 
	    ! defined $arg->{'w32cons_title'} || 
	             ($arg->{'w32cons_title'} eq '')) 
		{ die "Call to w32cons_title_set() failed, value associated w/ key 'w32cons_title' is undef/empty string"; }

	# This function defines keys:
	#
	#   KEY              DESCRIPTION 
	#   ___              ___________ 
        #   w32cons_title    The title of the console window. 

	# Function: Title() 
	#   Get (or set) the title of the console window. 

	if (my $rv = $self->{'CONS'}->Title ($arg->{'w32cons_title'})) 
	     { undef; }
	else { warn ("Function Title() returned w/ error. Unable to set the title of the console display window. ", $!, $^E); }

	return (1);
}

# THIS FUNCTION UNUSED AT PRESENT...

sub w32cons_write {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to w32cons_write() failed, argument must be hash reference"; }

	if (! exists  $arg->{'ref'} || 
	    ! defined $arg->{'ref'} || 
	             ($arg->{'ref'} eq '') || 
	      ! (ref ($arg->{'ref'}) eq 'ARRAY')) 
		{ die "Call to w32cons_write() failed, value associated w/ key 'ref' is must be array reference"; }

	if (! exists  $arg->{'xpos'} || 
	    ! defined $arg->{'xpos'} || 
	             ($arg->{'xpos'} eq '') || 
	           ! ($arg->{'ypos'} =~ /^\d+?$/)) 
		{ die "Call to w32cons_write() failed, value associated w/ key 'xpos' is must be one or more digits"; }

	if (! exists  $arg->{'ypos'} || 
	    ! defined $arg->{'ypos'} || 
	             ($arg->{'ypos'} eq '') || 
	           ! ($arg->{'ypos'} =~ /^\d+?$/)) 
		{ die "Call to w32cons_write() failed, value associated w/ key 'ypos' is must be one or more digits"; }

	my $ct = 1;

	foreach my $line (@{ $arg->{'ref'} }) {

		# Function: Write() 
		#   Write characters in the console display. 

		if (my $rv = $self->{'CONS'}->WriteChar ($line, $arg->{'xpos'}, $arg->{'ypos'})) 
		     { undef; }
		else { warn ("Function Write() returned w/ error while writing line " . 
		             $ct . " at " . $arg->{'xpos'} . "," . $arg->{'ypos'} . " (x,y coords). ", $!, $^E); }

		$arg->{'ypos'}++;
		$ct++;
	}

	return (1);
}

# Function: w32cons_refresh_display(): 
#   A fancy version of w32cons_write().

sub w32cons_refresh_display {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to w32cons_refresh_display() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp'} || 
	    ! defined $arg->{'dsp'} || 
	      ! (ref ($arg->{'dsp'}) eq 'ARRAY')) 
		{ die "Call to w32cons_refresh_display() failed, value associated w/ key 'dsp' must be array reference"; }

	if (! exists  $arg->{'dsp_prev'} || 
	    ! defined $arg->{'dsp_prev'} || 
	      ! (ref ($arg->{'dsp_prev'}) eq 'ARRAY')) 
		{ die "Call to w32cons_refresh_display() failed, value associated w/ key 'dsp_prev' must be array reference"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to w32cons_refresh_display() failed, value of key 'dsp_xpad' must be numeric"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to w32cons_refresh_display() failed, value of key 'dsp_ypad' must be numeric"; }

	my $objDisplay = $self->{'obj'}->{'display'};

	LINE_BY_LINE: 
	  for my $lnum (0 .. (scalar (@{ $arg->{'dsp'} }) -1)) {

		# Test line from display lines array (dsp) for definedness/correct length.

		foreach my $key ('dsp', 'dsp_prev') {

			if (! exists  $arg->{$key}->[$lnum] && 
			    ! defined $arg->{$key}->[$lnum] && 
				     ($arg->{$key}->[$lnum] eq '') && 
			   ! (length ($arg->{$key}->[$lnum]) == $objDisplay->{'d_width'})) {

				die "Display array '" . $key . 
				    "' indice '" . $lnum . 
				    "' holds string w/ wrong length ('" . $objDisplay->{'d_width'} . 
				    "' chars width req'd)";
			}
		}

		# Compare line currently displayed with the line which is about to be written over the top of it:
		#   - If the two lines are identical, there is no need to write this line to the display.
		#   - If the two lines are not identical, the display will need to be updated with the new line.

		if ($arg->{'dsp'}->[$lnum] eq $arg->{'dsp_prev'}->[$lnum]) {

			next LINE_BY_LINE;
		}
		else {

			# Find the offset of the first character which does not match.

			my $mmofs = -1;
			MISMATCH_OFS: 
			  for my $lofs (0 .. (length ($arg->{'dsp'}->[$lnum]) - 1)) {

				# Compare display line with previous display line, character by 
				# character until the first mismatched character is found.

				if ((substr $arg->{'dsp'}->[$lnum],      $lofs, 1) eq 
				    (substr $arg->{'dsp_prev'}->[$lnum], $lofs, 1)) {

					next MISMATCH_OFS;
				}
				else {

					$mmofs = $lofs;
					last MISMATCH_OFS;
				}
			}

			if ($mmofs == -1) {

				warn "Comparison of dsp line against dsp_prev found no mismatched character.";
				next LINE_BY_LINE;
			}

			# Find the offset of the last character which does not match (calculate the 
			# length of the substring of mismatched characters: $mismatch_len).
			#
			#   If mismatched character was found in the string comparison operation (performed above):
			#     - mismatch_ofs will be set to the offset of the first mismatched character.
			#   Otherwise:
			#     - mismatch_ofs will be set to -1.
			#     - skip this step (don't attempt to calculate length of substring of mismatched characters).

			my $mmlen = -1;

			MISMATCH_LEN: 
			  for my $lofs (0 .. (length ($arg->{'dsp'}->[$lnum]) - 1)) {

				# Compare display line with previous display line, character by 
				# character until the first mismatched character is found.

				my $rofs = (length ($arg->{'dsp'}->[$lnum]) - $lofs) - 1;

				if ((substr $arg->{'dsp'}->[$lnum],      $rofs, 1) eq 
				    (substr $arg->{'dsp_prev'}->[$lnum], $rofs, 1)) {

					next MISMATCH_LEN;
				}
				else {

					$mmlen = ($rofs - $mmofs) + 1;
					last MISMATCH_LEN;
				}
			}

			# If *either* mmofs or mmlen equal -1:
			#
			#   - The length of a mismatched substring could not be determined.
			#   - Skip ahead to next display line.

			if (($mmofs == -1) || 
			    ($mmlen == -1)) {

				next LINE_BY_LINE;
			}

			# Update the display console (only characters different than those already displayed).

			if (my $rv = $self->{'CONS'}->WriteChar 
			      ((substr $arg->{'dsp'}->[$lnum], $mmofs, $mmlen),   # String written to console display.
			       ($mmofs + $arg->{'dsp_xpad'}),                     # X-coordinate where string is written.
			       ($lnum  + $arg->{'dsp_ypad'})))                    # Y-coordinate where string is written.
			     { undef; }
			else { warn ("Call to WriteChar() returned w/ error writing string at '" . 
			             ($mmofs + $arg->{'dsp_xpad'}) . "','" . 
			             ($lnum  + $arg->{'dsp_ypad'}) . "' (X,Y coords)", $!, $^E); }
		}
	}

	return (1);
}

sub w32cons_cursor_invisible {

	my $self = shift;

	# Set console cursor invisible: 
	#   Set size and visibility without affecting position.

	if (my $rv = $self->{'CONS'}->Cursor (-1, -1, 0, 0)) {

		my $function = 'Cursor';

		if (! defined $rv) { warn ("Function " . $function . "() returned w/ error (undef). ",           $!, $^E); }
		elsif ($rv eq "")  { warn ("Function " . $function . "() returned w/ error (empty string). ",    $!, $^E); }
		elsif (! $rv)      { warn ("Function " . $function . "() returned w/ error (evaluates false). ", $!, $^E); }
		elsif ($rv)        { undef; }   # Successful return value.
		else               { undef; }   # Something other than success or failure.
	}

	return (1);
}

sub w32cons_cursor_visible {

	my $self = shift;

	# Set console cursor visible: 
	#   Set size and visibility without affecting position.

	if (my $rv = $self->{'CONS'}->Cursor (-1, -1, 50, 1)) {

		my $function = 'Cursor';

		if (! defined $rv) { warn ("Function " . $function . "() returned w/ error (undef). ",           $!, $^E); }
		elsif ($rv eq "")  { warn ("Function " . $function . "() returned w/ error (empty string). ",    $!, $^E); }
		elsif (! $rv)      { warn ("Function " . $function . "() returned w/ error (evaluates false). ", $!, $^E); }
		elsif ($rv)        { undef; }   # Successful return value.
		else               { undef; }   # Something other than success or failure.
	}

	return (1);
}

sub w32cons_cursor_tleft_dsp {

	my $self = shift;

	$self->{'CONS'}->Cursor (0, 0);

	return (1);
}

sub w32cons_cursor_bleft_dsp {

	my $self = shift;

	$self->{'CONS'}->Cursor (0, $self->{'w32cons_bottom_row'});

	return (1);
}

sub w32cons_cursor_move {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to w32cons_cursor_move() failed, argument must be hash reference"; }

	if (! exists  $arg->{'xpos'} || 
	    ! defined $arg->{'xpos'} || 
	           ! ($arg->{'xpos'} =~ /^\d+?$/)) 
		{ die "Call to w32cons_cursor_move() failed, value of key 'xpos' must be numeric"; }

	if (! exists  $arg->{'ypos'} || 
	    ! defined $arg->{'ypos'} || 
	           ! ($arg->{'ypos'} =~ /^\d+?$/)) 
		{ die "Call to w32cons_cursor_move() failed, value of key 'ypos' must be numeric"; }

	if (exists  $self->{'w32cons_curs_xpos'} && 
	    defined $self->{'w32cons_curs_xpos'} && 
	         ! ($self->{'w32cons_curs_xpos'} eq '') && 
	           ($self->{'w32cons_curs_xpos'} =~ /^\d+?$/) && 
	    exists  $self->{'w32cons_curs_ypos'} && 
	    defined $self->{'w32cons_curs_ypos'} && 
	         ! ($self->{'w32cons_curs_ypos'} eq '') && 
	           ($self->{'w32cons_curs_ypos'} =~ /^\d+?$/)) {

		if ($arg->{'xpos'} == $self->{'w32cons_curs_xpos'} && 
		    $arg->{'ypos'} == $self->{'w32cons_curs_ypos'}) {

			# No need to update console cursor position 
			#   (already present at the requested position).

			return (1);
		}
	}
	else {

		if (! exists  $self->{'w32cons_curs_xpos'} || 
		    ! defined $self->{'w32cons_curs_xpos'} || 
			     ($self->{'w32cons_curs_xpos'} eq '') || 
			   ! ($self->{'w32cons_curs_xpos'} =~ /^\d+?$/)) {

			$self->{'w32cons_curs_xpos'} = $arg->{'xpos'};
		}

		if (! exists  $self->{'w32cons_curs_ypos'} || 
		    ! defined $self->{'w32cons_curs_ypos'} || 
			     ($self->{'w32cons_curs_ypos'} eq '') || 
			   ! ($self->{'w32cons_curs_ypos'} =~ /^\d+?$/)) {

			$self->{'w32cons_curs_ypos'} = $arg->{'ypos'};
		}
	}

	$self->{'CONS'}->Cursor ($arg->{'xpos'}, $arg->{'ypos'});

	if (! ($self->{'w32cons_curs_xpos'} == $arg->{'xpos'})) 
		{ $self->{'w32cons_curs_xpos'} = $arg->{'xpos'}; }

	if (! ($self->{'w32cons_curs_ypos'} == $arg->{'ypos'})) 
		{ $self->{'w32cons_curs_ypos'} = $arg->{'ypos'}; }

	return (1);
}

sub w32cons_fg_white_bg_black {

	my $self = shift;

	for my $line_num (0 .. $self->{'w32cons_bottom_row'}) {

		# FillAttr (attribute, number, col, row)
		#   Fills the specified number of consecutive attributes, beginning at 
		#   *col*, *row*, with the value specified in *attribute*. Returns the 
		#   number of attributes filled, or "undef" on errors. See also: 
		#   "FillChar". 
		#     Example: 
		#       $CONSOLE->FillAttr ($FG_BLACK | $BG_BLACK, 80*25, 0, 0);

		$self->{'CONS'}->FillAttr 
		  (($FG_WHITE | $BG_BLACK), 
		   ($self->{'w32cons_last_col'} - 1), 
		   0, 
		   $line_num);
	}

	return (1);
}

sub w32cons_close {

	my $self = shift;

	# w32cons_close: Set console attributes back to original state (before program execution). 

	# Function: Attr() 
	#   Set attributes associated with console, and used by function Write().

	if (my $rv = $self->{'CONS'}->Attr ($self->{'w32cons_attr_orig'})) 
	     { undef; }
	else { warn ("Function Attr() returned w/ error. ", $!, $^E); }

	return (1);
}

# Functions: Display console colorization.
#
#   ____			___________			___________
#   NAME			DESCRIPTION			WRAPPER FOR
#   ____			___________			___________
#   colorize_display()		Set ANSI-ish console colors.	FillAttr()
#   colorize_reverse()		...				FillAttr()
#   colorize_combine_attrs()	...				-

sub colorize_display {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to colorize_display() failed, argument must be hash reference"; }

	if (! exists  $arg->{'c_elements'} || 
	    ! defined $arg->{'c_elements'} || 
	           ! (ref ($arg->{'c_elements'}) eq 'ARRAY')) 
		{ die "Call to colorize_display() failed, value associated with 'c_elements' key must be a hash reference"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_display() failed, value of key 'dsp_xpad' must be numeric"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_display() failed, value of key 'dsp_ypad' must be numeric"; }

	for my $lnum (0 .. $self->{'w32cons_bottom_row'}) {

		foreach my $c_element (@{ $arg->{'c_elements'} }) {

			if (($lnum >= ($c_element->{'y'})) && 
			    ($lnum <  ($c_element->{'y'} + $c_element->{'ht'}))) {

				$self->{'CONS'}->FillAttr 
				  ($self->colorize_combine_attrs ({ 'c_element_attr' => $c_element->{'attr'} }), 
				   $c_element->{'wd'}, 
				   ($c_element->{'x'} + $arg->{'dsp_xpad'}), 
				   ($lnum + $arg->{'dsp_ypad'}));
			}
		}
	}

	return (1);
}

sub colorize_reverse {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to colorize_reverse() failed, argument must be hash reference"; }

	if (! exists  $arg->{'c_elements'} || 
	    ! defined $arg->{'c_elements'} || 
	           ! (ref ($arg->{'c_elements'}) eq 'ARRAY')) 
		{ die "Call to colorize_reverse() failed, value associated with 'c_elements' key must be a hash reference"; }

	if (! exists  $arg->{'xc'} || 
	    ! defined $arg->{'xc'} || 
	           ! ($arg->{'xc'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_reverse() failed, value of key 'xc' must be numeric"; }

	if (! exists  $arg->{'yc'} || 
	    ! defined $arg->{'yc'} || 
	           ! ($arg->{'yc'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_reverse() failed, value of key 'yc' must be numeric"; }

	if (! exists  $arg->{'width'} || 
	    ! defined $arg->{'width'} || 
	           ! ($arg->{'width'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_reverse() failed, value of key 'width' must be numeric"; }

	if (! exists  $arg->{'action'} || 
	    ! defined $arg->{'action'} || 
	          ! (($arg->{'action'} eq 'on') || ($arg->{'action'} eq 'off'))) 
		{ die "Call to colorize_reverse() failed, value of key 'action' must be 'on' or 'off'"; }

	my $objDisplay = $self->{'obj'}->{'display'};

	# Function colorize():
	#   ________	___________
	#   Argument	Description
	#   ________	___________
	#   c_elements	Active c_elements list.
	#   xc		X coordinate of block to highlight.
	#   yc		Y coordinate of block to highlight.
	#   width	Width (in characters) of area to colorize.
	#   action	[off | on], turn highlight off/on.

	my $on_off;
	if (defined $arg->{'action'} && 
	           ($arg->{'action'} eq 'off')) {

		$on_off = 'attr';
	}
	elsif (defined $arg->{'action'} && 
	              ($arg->{'action'} eq 'on')) {

		$on_off= 'rvrs';
	}

	foreach my $c_element (@{ $arg->{'c_elements'} }) {

		if (((($arg->{'xc'} >= ($c_element->{'x'} + $objDisplay->{'dsp_xpad'})) && 
		      ($arg->{'xc'} <  ($c_element->{'x'} + $objDisplay->{'dsp_xpad'} + $c_element->{'wd'}))) && 

		     (($arg->{'yc'} >= ($c_element->{'y'} + $objDisplay->{'dsp_ypad'})) && 
		      ($arg->{'yc'} <  ($c_element->{'y'} + $objDisplay->{'dsp_ypad'} + $c_element->{'ht'})))) && 

		      (exists  $c_element->{$on_off} && 
		       defined $c_element->{$on_off} && 
			    ! ($c_element->{$on_off} eq '') && 
			 (ref ($c_element->{$on_off}) eq 'ARRAY'))) {

			# FillAttr [attribute, number, col, row] 
			#   Fills the specified number of consecutive attributes, beginning at 
			#   *col*, *row*, with the value specified in *attribute*. Returns the 
			#   number of attributes filled, or "undef" on errors. See also: 
			#   "FillChar". 
			#   Example: 
			#     $CONSOLE->FillAttr ($FG_BLACK | $BG_BLACK, 80*25, 0, 0); 

			$self->{'CONS'}->FillAttr 
			  ($self->colorize_combine_attrs ({ 'c_element_attr' => $c_element->{$on_off} }), 
			   $arg->{'width'}, 
			   $arg->{'xc'}, 
			   $arg->{'yc'});
		}
	}

	return (1);
}

sub colorize_combine_attrs {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to colorize_combine_attrs() failed, argument must be hash reference"; }

	if (! exists  $arg->{'c_element_attr'} || 
	    ! defined $arg->{'c_element_attr'} || 
	           ! (ref ($arg->{'c_element_attr'}) eq 'ARRAY')) 
		{ die "Call to colorize_combine_attrs() failed, value associated with 'c_element_attr' key must be array reference"; }

	my $attr_combined;

	if (exists  $arg->{'c_element_attr'} && 
	    defined $arg->{'c_element_attr'} && 
		 ! ($arg->{'c_element_attr'} eq '') && 
	      (ref ($arg->{'c_element_attr'}) eq 'ARRAY')) {

		for my $idx (0 .. (scalar (@{ $arg->{'c_element_attr'} }) - 1)) {

			if (exists  $arg->{'c_element_attr'}->[$idx] && 
			    defined $arg->{'c_element_attr'}->[$idx] && 
				 ! ($arg->{'c_element_attr'}->[$idx] eq '') && 
			    exists  $self->{ $arg->{'c_element_attr'}->[$idx] } && 
			    defined $self->{ $arg->{'c_element_attr'}->[$idx] } && 
				 ! ($self->{ $arg->{'c_element_attr'}->[$idx] } eq '')) {

				if ($idx == 0) {

					$attr_combined = 
					  $self->{ $arg->{'c_element_attr'}->[$idx] };
				}
				else {

					$attr_combined = 
					  ($attr_combined | $self->{ $arg->{'c_element_attr'}->[$idx] });
				}
			}
		}
	}

	return ($attr_combined);
}

# Functions: Mouse event handlers.
#
#   ____		___________
#   NAME		DESCRIPTION
#   ____		___________
#   lmouse()		Left  mouse button handler. Call function based upon context.
#   rmouse()		Right mouse button handler. Call function based upon context.
#   mouse_over()	Highlight character below mouse pointer, restore attributes to character at previous mouse position.

sub lmouse {

	my $self = shift;

	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $xpos = $objEventLoop->{'evt'}->[1];
	my $ypos = $objEventLoop->{'evt'}->[2];

	my @dsp_pos;
	SEARCH_DSP_POS: 
	  foreach my $pos 
	    ($objEditor->{'dsp_pos'} .. ($objEditor->{'dsp_pos'} + 
	                                ($objEditor->{'sz_line'} * 
	                                 $objEditor->{'sz_column'}))) {

		my ($xc, $yc) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $pos, 
		       'dsp_pos'  => $objEditor->{'dsp_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		if ((($xpos == ($xc + $objDisplay->{'dsp_xpad'})) || 
		     ($xpos == ($xc + $objDisplay->{'dsp_xpad'} + 1))) && 
		     ($ypos == ($yc + $objDisplay->{'dsp_ypad'}))) {

			if ($objCursor->{'curs_ctxt'} == 0) {

				# Cursor in "line" context: highlight line 
				# beginning at align_line_boundary().

				my $lb_pos = $objCursor->align_line_boundary ({ 'pos' => $pos });
				if (defined $lb_pos && 
				            $lb_pos =~ /^\d+?$/) {

					$objCursor->{'curs_pos'} = $lb_pos;
				}
			}
			elsif ($objCursor->{'curs_ctxt'} == 1) {

				# Cursor in "word" context: highlight word 
				# beginning at align_word_boundary().

				my $wb_pos = $objCursor->align_word_boundary ({ 'pos' => $pos });
				if (defined $wb_pos && 
				            $wb_pos =~ /^\d+?$/) {

					$objCursor->{'curs_pos'} = $wb_pos;
				}
			}
			elsif ($objCursor->{'curs_ctxt'} == 2) {

				$objCursor->{'curs_pos'} = $pos;
			}
			else {

				return (undef);
			}

			last SEARCH_DSP_POS;
		}
	}

	# $self->{'CONS'}->FillAttr (($FG_BLACK | $BG_LIGHTMAGENTA), 1, $xpos, $ypos);

	return (1); 
}

sub rmouse {

	my $self = shift;

	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $xpos = $objEventLoop->{'evt'}->[1];
	my $ypos = $objEventLoop->{'evt'}->[2];

	$self->{'CONS'}->FillAttr (($FG_BLACK | $BG_LIGHTBLUE), 1, $xpos, $ypos);

	return (1);
}

sub mouse_over {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to mouse_over() failed, argument must be hash reference"; }

	if (! exists  $arg->{'mouse_over_x'} || 
	    ! defined $arg->{'mouse_over_x'} || 
	           ! ($arg->{'mouse_over_x'} =~ /^\d\d?\d?$/)) 
		{ die "Call to mouse_over() failed, value of key 'mouse_over_x' must be numeric"; }

	if (! exists  $arg->{'mouse_over_y'} || 
	    ! defined $arg->{'mouse_over_y'} || 
	           ! ($arg->{'mouse_over_y'} =~ /^\d\d?\d?$/)) 
		{ die "Call to mouse_over() failed, value of key 'mouse_over_y' must be numeric"; }

	if (! exists  $arg->{'mouse_over_x_prev'} || 
	    ! defined $arg->{'mouse_over_x_prev'} || 
	           ! ($arg->{'mouse_over_x_prev'} =~ /^\d\d?\d?$/)) 
		{ die "Call to mouse_over() failed, value of key 'mouse_over_x_prev' must be numeric"; }

	if (! exists  $arg->{'mouse_over_y_prev'} || 
	    ! defined $arg->{'mouse_over_y_prev'} || 
	           ! ($arg->{'mouse_over_y_prev'} =~ /^\d\d?\d?$/)) 
		{ die "Call to mouse_over() failed, value of key 'mouse_over_y_prev' must be numeric"; }

	# Restore original attributes to character at previous mouseover X,Y coordinate.

	$self->{'CONS'}->WriteAttr 
	  ($self->{'mouse_over_attr'}, 
	   $arg->{'mouse_over_x_prev'}, 
	   $arg->{'mouse_over_y_prev'});

	# ReadChar [number, col, row]
	#   Reads the specified *number* of consecutive characters, beginning at
	#   *col*, *row*, from the console. Returns a string containing the
	#   characters read, or "undef" on errors. You can then pass the
	#   returned variable to "WriteChar" to restore the saved characters on
	#   screen. See also: "ReadAttr", "ReadRect".
	# 
	#   Example:
	#     $chars = $CONSOLE->ReadChar (80 * 25, 0, 0);

	# Read/store character underneath mouse pointer.

	$self->{'mouse_over_char'} = 
	  $self->{'CONS'}->ReadChar 
	    (1, 
	     $arg->{'mouse_over_x'}, 
	     $arg->{'mouse_over_y'});

	# ReadAttr (number, col, row)
	#   Reads the specified *number* of consecutive attributes, beginning at
	#   *col*, *row*, from the console. Returns the attributes read (a
	#   variable containing one character for each attribute), or "undef" on
	#   errors. You can then pass the returned variable to "WriteAttr" to
	#   restore the saved attributes on screen. See also: "ReadChar",
	#   "ReadRect".
	# 
	#     Example:
	#       $colors = $CONSOLE->ReadAttr(80*25, 0, 0);

	# Read/store attributes of character underneath mouse pointer

	$self->{'mouse_over_attr'} = 
	  $self->{'CONS'}->ReadAttr 
	    (1, 
	     $arg->{'mouse_over_x'}, 
	     $arg->{'mouse_over_y'});

	# WriteAttr (attrs, col, row)
	#   Writes the attributes in the string *attrs*, beginning at *col*,
	#   *row*, without affecting the characters that are on screen. The
	#   string attrs can be the result of a "ReadAttr" function, or you can
	#   build your own attribute string; in this case, keep in mind that
	#   every attribute is treated as a character, not a number (see
	#   example). Returns the number of attributes written or "undef" on
	#   errors. See also: "Write", "WriteChar", "WriteRect".
	# 
	#   Example:
	#     $CONSOLE->WriteAttr ($attrs, 0, 0);
	# 
	#   Note the use of chr()...
	#     $attrs = chr ($FG_BLACK | $BG_WHITE) x 80;
	#     $CONSOLE->WriteAttr ($attrs, 0, 0);

	# Hi-light character underneath mouse pointer.

	$self->{'CONS'}->WriteAttr 
	  (chr ($FG_BLACK | $BG_LIGHTRED), 
	   $arg->{'mouse_over_x'}, 
	   $arg->{'mouse_over_y'});

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::Console (ZHex/Console.pm) - Console Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::Console module is a wrapper around the functions provided by 
Win32::Console. It serves to make the use of Win32::Console easier for the 
author.

Usage:

    use ZHex::BoilerPlate qw(new obj_init $VERS);
    my $objConsole = $self->{'obj'}->{'console'};
    $objConsole->w32cons_cursor_invisible();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 colorize_combine_attrs
Method colorize_combine_attrs()...
= cut

=head2 colorize_display
Method colorize_display()...
= cut

=head2 colorize_reverse
Method colorize_reverse()...
= cut

=head2 init
Method init()...
= cut

=head2 lmouse
Method lmouse()...
= cut

=head2 mouse_over
Method mouse_over()...
= cut

=head2 rmouse
Method rmouse()...
= cut

=head2 w32cons_clear
Method w32cons_clear()...
= cut

=head2 w32cons_close
Method w32cons_close()...
= cut

=head2 w32cons_cursor_bleft_dsp
Method w32cons_cursor_bleft_dsp()...
= cut

=head2 w32cons_cursor_invisible
Method w32cons_cursor_invisible()...
= cut

=head2 w32cons_cursor_move
Method w32cons_cursor_move()...
= cut

=head2 w32cons_cursor_tleft_dsp
Method w32cons_cursor_tleft_dsp()...
= cut

=head2 w32cons_cursor_visible
Method w32cons_cursor_visible()...
= cut

=head2 w32cons_fg_white_bg_black
Method w32cons_fg_white_bg_black()...
= cut

=head2 w32cons_init
Method w32cons_init()...
= cut

=head2 w32cons_mode_get
Method w32cons_mode_get()...
= cut

=head2 w32cons_mode_set
Method w32cons_mode_set()...
= cut

=head2 w32cons_refresh_display
Method w32cons_refresh_display()...
= cut

=head2 w32cons_size_set
Method w32cons_size_set()...
= cut

=head2 w32cons_termcap
Method w32cons_termcap()...
= cut

=head2 w32cons_title_get
Method w32cons_title_get()...
= cut

=head2 w32cons_title_set
Method w32cons_title_set()...
= cut

=head2 w32cons_write
Method w32cons_write()...
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

