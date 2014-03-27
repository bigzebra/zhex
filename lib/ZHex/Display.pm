#!/usr/bin/perl

package ZHex::Display;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common qw(new obj_init $VERS);

BEGIN { require Exporter;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(); 
}

# Functions: Initialization (start up) 
#
#   _____________		___________
#   Function Name		Description
#   _____________		___________
#   init()			Initialize member variables.
#   dimensions_set()		Store width/height of display (X,Y values in characters).
#   padding_set()		Store left/top margin: used to pad editor display (values in characters).
#   d_elements_set()		Accessor member function for $self->{'d_elements'} (member variable).
#   c_elements_set()		Accessor member function for $self->{'c_elements'} (member variable).
#   dsp_prev_init()		Initialization function for $self->{'dsp_prev'} (member variable).
#   dsp_set()			Accessor member function for $self->{'dsp'} (member variable).
#   dsp_prev_set()		Accessor member function for $self->{'dsp_prev'} (member variable).

sub init {

	my $self = shift;

	$self->{'d_width'}  = '';     # Set via member function dimensions_set().
	$self->{'d_height'} = '';     # Set via member function dimensions_set().

	$self->{'dsp_xpad'} = '';     # Set via member function padding_set().
	$self->{'dsp_ypad'} = '';     # Set via member function padding_set().

	$self->{'d_elements'} = '';   # Set via member function d_elements_set().
	$self->{'c_elements'} = '';   # Set via member function c_elements_set().

	$self->{'dsp'}      = '';     # Set via member function dsp_set().
	$self->{'dsp_prev'} = '';     # Set via member function dsp_prev_set().

	return (1);
}

sub dimensions_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dimensions_init() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_width'} || 
	    ! defined $arg->{'d_width'} || 
	           ! ($arg->{'d_width'} =~ /^\d+?$/)) 
		{ die "Call to dimensions_init() failed, value of key 'd_width' must be numeric"; }

	if (! exists  $arg->{'d_height'} || 
	    ! defined $arg->{'d_height'} || 
	           ! ($arg->{'d_height'} =~ /^\d+?$/)) 
		{ die "Call to dimensions_init() failed, value of key 'd_height' must be numeric"; }

	$self->{'d_width'}  = $arg->{'d_width'};    # Display width:  Number of characters in display console (horizontally).
	$self->{'d_height'} = $arg->{'d_height'};   # Display height: Number of characters in display console (vertically).

	return (1);
}

sub padding_set {

	my $self = shift;
	my $arg  = shift;

	if (!defined $arg || 
	     ! (ref ($arg) eq 'HASH')) 
		{ die "Call to padding_init() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d+?$/)) 
		{ die "Call to padding_init() failed, value associated w/ key 'dsp_xpad' must be numeric"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d+?$/)) 
		{ die "Call to padding_init() failed, value associated w/ key 'dsp_ypad' must be numeric"; }

	$self->{'dsp_ypad'} = $arg->{'dsp_ypad'};   # Display padding (Top margin):  number of chars padding the editor display vertically   from top.
	$self->{'dsp_xpad'} = $arg->{'dsp_xpad'};   # Display padding (Left margin): number of chars padding the editor display horizontally from left.

	return (1);
}

sub d_elements_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to d_elements_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_elements'} || 
	    ! defined $arg->{'d_elements'} || 
	      ! (ref ($arg->{'d_elements'}) eq 'HASH')) 
		{ die "Call to d_elements_set() failed, value associated w/ key 'd_elements' must hash reference"; }

	$self->{'d_elements'} = $arg->{'d_elements'};

	return (1);
}

sub c_elements_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to c_elements_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'c_elements'} || 
	    ! defined $arg->{'c_elements'} || 
	      ! (ref ($arg->{'c_elements'}) eq 'HASH')) 
		{ die "Call to c_elements_set() failed, value associated w/ key 'c_elements' must be a hash reference"; }

	$self->{'c_elements'} = $arg->{'c_elements'};

	return (1);
}

sub dsp_prev_init {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dsp_prev_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_width'} || 
	    ! defined $arg->{'d_width'} || 
	             ($arg->{'d_width'} eq '') || 
	      ! ($arg->{'d_width'} =~ /^\d+?$/)) 
		{ die "Call to dsp_prev_init() failed, value associated w/ key 'd_width' must be one or more digits"; }

	if (! exists  $arg->{'d_height'} || 
	    ! defined $arg->{'d_height'} || 
	             ($arg->{'d_height'} eq '') || 
	      ! ($arg->{'d_height'} =~ /^\d+?$/)) 
		{ die "Call to dsp_prev_init() failed, value associated w/ key 'd_height' must be one or more digits"; }

	my $dsp_prev = 
	  $self->generate_blank_display 
	    ({ 'd_width'  => $arg->{'d_width'}, 
	       'd_height' => $arg->{'d_height'} });

	return ($dsp_prev);
}

sub dsp_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dsp_prev_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp'} || 
	    ! defined $arg->{'dsp'} || 
	      ! (ref ($arg->{'dsp'}) eq 'ARRAY')) 
		{ die "Call to dsp_set() failed, value associated w/ key 'dsp' must be array reference"; }

	if (! (scalar (@{ $arg->{'dsp'} }) == $self->{'d_height'})) 
		{ die "Call to dsp_set() failed, value associated w/ key 'dsp' did not have correct number of elements defined"; }

	$self->{'dsp'} = $arg->{'dsp'};

	return (1);
}

sub dsp_prev_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dsp_prev_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp_prev'} || 
	    ! defined $arg->{'dsp_prev'} || 
	      ! (ref ($arg->{'dsp_prev'}) eq 'ARRAY')) 
		{ die "Call to dsp_prev_set() failed, value associated w/ key 'dsp_prev' must be array reference"; }

	if (! (scalar (@{ $arg->{'dsp_prev'} }) == $self->{'d_height'})) 
		{ die "Call to dsp_prev_set() failed, value associated w/ key 'dsp_prev' did not have correct number of elements defined"; }

	$self->{'dsp_prev'} = $arg->{'dsp_prev'};

	return (1);
}

# Functions: Display handling.
#
#   _____________		___________
#   Function Name		Description
#   _____________		___________
#   d_elements_tbl()		...
#   d_elements_init()      	Initialize display elements data structure.
#   c_elements_init()		...
#   active_c_elements()		...
#   generate_blank_e_contents()	Return element-sized array of blank lines.
#   generate_blank_display()	Return display-sized array of blank lines.
#   add_elements_to_display()	Assemble display elements together into array of lines.

sub d_elements_tbl {

	my $self = shift;

	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEvent     = $self->{'obj'}->{'event'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	# Editor Display Elements: Coordinates/Dimensions.
	#
	#   ____		___________			_____	________
	#   Name		Description			Width	HPadding
	#   ____		___________			_____	________
	#   column_titles	Banner across top of display.	  114	-
	#   ofs_hex		Offset column (hex).		   22	2
	#   ofs_dec		Offset column (dec).		   18	2
	#   editor_disp		Hex columns (editor display).	   43	2
	#   char_disp		Text columns (editor display).	   18	1
	#   line_num		Line number column.		    6	2
	#   sep			Horizontal seperator (bottom).	  114	-

	# Display Element Table: d_element_tbl
	#
	#   Each list item is a reference to array containing elements: 
	#
	#     Element Name	Description
	#     ____________	___________
	#     d_element		...
	#     e_width		...
	#     e_height		...
	#     hpadding		...
	#     vpadding		...
	#     color		...
	#     subref		...

	#    ELEMENT NAME         WIDT HEIGHT                     H  V  COLORIZATION ELEMENTS (c_elements)                                                SUBREF
	#    ____________         ____ ______                     _  _  __________________________________                                                ______
	my $d_element_tbl = 
	  [ ['column_titles',     114, 3,                         2, 0, ['column_titles'],                                                                sub{return($objEditor->gen_hdr({'d_elements'=>$self->{'d_elements'}}));}], 
	    ['ofs_hex',           22,  $objEditor->{'sz_column'}, 2, 0, ['ofs_hex_col1', 'ofs_hex_div', 'ofs_hex_col2'],                                  sub{return($objEditor->gen_ofs_hex({'pos'=>$objEditor->{'dsp_pos'},'sz_line'=>$objEditor->{'sz_line'},'sz_column'=>$objEditor->{'sz_column'},'f_size'=>$objFile->file_len()}));}], 
	    ['ofs_dec',           18,  $objEditor->{'sz_column'}, 2, 0, ['ofs_dec_col1', 'ofs_dec_div', 'ofs_dec_col2'],                                  sub{return($objEditor->gen_ofs_dec({'pos'=>$objEditor->{'dsp_pos'},'sz_line'=>$objEditor->{'sz_line'},'sz_column'=>$objEditor->{'sz_column'},'f_size'=>$objFile->file_len()}));}], 
	    ['editor_disp',       43,  $objEditor->{'sz_column'}, 2, 0, ['editor_disp_col1', 'editor_disp_col2', 'editor_disp_col3', 'editor_disp_col4'], sub{return($objEditor->gen_hex_cols({'pos'=>$objEditor->{'dsp_pos'},'sz_line'=>$objEditor->{'sz_line'},'sz_column'=>$objEditor->{'sz_column'},'f_size'=>$objFile->file_len(),'col_ct'=>4,'hpad'=>1,'prefix'=>'0x'}));}], 
	    ['char_disp',         18,  $objEditor->{'sz_column'}, 1, 0, ['char_disp'],                                                                    sub{return($objEditor->gen_char({'pos'=>$objEditor->{'dsp_pos'},'sz_line'=>$objEditor->{'sz_line'},'sz_column'=>$objEditor->{'sz_column'},'f_size'=>$objFile->file_len()}));}], 
	    ['line_num',          6,   $objEditor->{'sz_column'}, 2, 0, ['line_num'],                                                                     sub{return($objEditor->gen_lnum({'pos'=>$objEditor->{'dsp_pos'},'sz_line'=>$objEditor->{'sz_line'},'sz_column'=>$objEditor->{'sz_column'},'f_size'=>$objFile->file_len()}));}], 
	    ['sep',               114, 1,                         0, 2, ['sep'],                                                                          sub{return($objEditor->gen_sep({'d_elements'=>$self->{'d_elements'}}));}], 
	    ['dbg_mouse_evt',     17,  10,                        2, 1, ['dbg_mouse_evt'],                                                                sub{return($objDebug->dbg_mouse_evt($objEventLoop->{'evt'}));}], 
	    ['dbg_keybd_evt',     17,  8,                         2, 1, [],                                                                               sub{return($objDebug->dbg_keybd_evt($objEventLoop->{'evt'}));}], 
	    ['dbg_unmatched_evt', 17,  8,                         2, 1, ['dbg_unmatched_evt'],                                                            sub{return($objDebug->dbg_unmatched_evt($objEventLoop->{'evt'}));}], 
	    ['dbg_curs',          23,  5,                         2, 1, [],                                                                               sub{return($objDebug->dbg_curs());}], 
	    ['dbg_display',       25,  12,                        2, 1, ['dbg_display'],                                                                  sub{return($objDebug->dbg_display());}], 
	    ['dbg_count',         19,  4,                         1, 1, [],                                                                               sub{return($objDebug->dbg_count());}], 
	    ['dbg_console',       19,  8,                         1, 1, ['dbg_console'],                                                                  sub{return($objDebug->dbg_console());}], 
	    ['errmsg_queue',      116, 12,                        2, 1, ['errmsg_queue'],                                                                 sub{return($objDebug->errmsg_queue());}], 
	    ['search_box',        100, 3,                         0, 0, ['search_box'],                                                                   sub{return($objEvent->search_box());}] ];

	my $d_elements = {};
	foreach my $d_element (@{ $d_element_tbl }) {

		# ALWAYS THE SAME (AT INIT TIME)
		# ______________________________
		# e_xpos      = '' 
		# e_ypos      = '' 
		# enabled     =  1 
		# e_contents  = [] 
		# e_changed   =  0 

		$d_elements->{ $d_element->[0] } = 
		  { 'e_xpos'     => '', 
		    'e_ypos'     => '', 
		    'e_width'    => $d_element->[1], 
		    'e_height'   => $d_element->[2], 
		    'hpad'       => $d_element->[3], 
		    'vpad'       => $d_element->[4], 
		    'enabled'    => 1, 
		    'e_contents' => [], 
		    'e_changed'  => 0, 
		    'color'      => $d_element->[5], 
		    'subref'     => $d_element->[6] };
	}

	return ($d_elements);
}

sub d_elements_init {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEvent     = $self->{'obj'}->{'event'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Editor Display Elements: Coordinates/Dimensions.
	#
	# ____			___________			_____	________
	# Name			Description			Width	HPadding
	# ____			___________			_____	________
	# column_titles		Banner across top of display.	  117	-
	# ofs_hex		Offset column (hex).		   22	2
	# ofs_dec		Offset column (dec).		   18	2
	# editor_disp		Hex columns (editor display).	   43	2
	# char_disp		Text columns (editor display).	   21	1
	# line_num		Line number column.		    6	2
	# sep			Horizontal seperator (bottom).	  117	-

	my $d_elements = $self->d_elements_tbl();

	CALCULATE_HEADER_POSITION: {

		my $d_element_top_nm = 'column_titles';

		my $xpos = 0;
		my $ypos = 0;

		# Store X,Y coordinates for display element position.

		$d_elements->{$d_element_top_nm}->{'e_xpos'} = $xpos;
		$d_elements->{$d_element_top_nm}->{'e_ypos'} = $ypos;
	}

	CALCULATE_COLUMN_POSITIONS: {

		my $d_element_top_nm = 'column_titles';

		my $xpos = $d_elements->{$d_element_top_nm}->{'e_xpos'};

		my $ypos = $d_elements->{$d_element_top_nm}->{'e_ypos'}   + 
		           $d_elements->{$d_element_top_nm}->{'e_height'} + 
		           $d_elements->{$d_element_top_nm}->{'vpad'};

		my $prev_width = 0;
		my $prev_hpad  = 0;

		foreach my $d_element_nm 
		  ('ofs_hex', 
		   'ofs_dec', 
		   'editor_disp', 
		   'char_disp', 
		   'line_num') {

			# Calculate X,Y coordinates for display element position.

			$xpos = $xpos + $prev_width + $prev_hpad;

			# Store X,Y coordinates for display element position.

			$d_elements->{$d_element_nm}->{'e_xpos'} = $xpos;
			$d_elements->{$d_element_nm}->{'e_ypos'} = $ypos;

			# Store (temporarily) X,Y coordinates (used to calculate position of next element).

			$prev_width = $d_elements->{$d_element_nm}->{'e_width'};
			$prev_hpad  = $d_elements->{$d_element_nm}->{'hpad'};
		}
	}

	CALCULATE_HORIZ_SEP_POSITION: {

		my $d_element_sep_nm = 'sep';

		my $xpos = 1000;   # Set xpos greater than greatest possible left margin.
		my $ypos = 0;

		foreach my $d_element_nm 
		  ('ofs_hex', 
		   'ofs_dec', 
		   'editor_disp', 
		   'char_disp', 
		   'line_num') {

			if ($d_elements->{$d_element_nm}->{'enabled'} == 1) {

				# Use left edge of leftmost element as xpos for horizontal seperator element.

				if ($d_elements->{$d_element_nm}->{'e_xpos'} < $xpos) {

					$xpos = $d_elements->{$d_element_nm}->{'e_xpos'};
				}

				# Use bottom of lowest column as ypos for horizontal seperator element.

				if (($d_elements->{$d_element_nm}->{'e_ypos'}   + 
				     $d_elements->{$d_element_nm}->{'e_height'} + 
				     $d_elements->{$d_element_nm}->{'vpad'}) > $ypos) {

					$ypos = 
					  ($d_elements->{$d_element_nm}->{'e_ypos'}   + 
					   $d_elements->{$d_element_nm}->{'e_height'} + 
					   $d_elements->{$d_element_nm}->{'vpad'});
				}
			}
		}

		$d_elements->{$d_element_sep_nm}->{'e_xpos'} = $xpos;
		$d_elements->{$d_element_sep_nm}->{'e_ypos'} = $ypos;
	}

	CALCULATE_DEBUG_POSITIONS: {

		my $d_element_top_nm = 'column_titles';

		my $xpos = $d_elements->{'line_num'}->{'e_xpos'} + 
		           $d_elements->{'line_num'}->{'e_width'} + 
		           $d_elements->{'line_num'}->{'hpad'};

		my $ypos = $d_elements->{$d_element_top_nm}->{'e_ypos'};

		my $prev_height = 0;
		my $prev_vpad   = 0;

		foreach my $d_element_nm 
		  ('dbg_mouse_evt', 
		   'dbg_keybd_evt', 
		   'dbg_unmatched_evt', 
		   'dbg_curs', 
		   'dbg_display', 
		   'dbg_count', 
		   'dbg_console') {

			# Calculate X,Y coordinates for display element position.

			$ypos = $ypos + $prev_height + $prev_vpad;

			# Store X,Y coordinates for display element position.

			$d_elements->{$d_element_nm}->{'e_xpos'} = $xpos;
			$d_elements->{$d_element_nm}->{'e_ypos'} = $ypos;

			# Store (temporarily) X,Y coordinates (used to calculate position of next element).

			$prev_height = $d_elements->{$d_element_nm}->{'e_height'};
			$prev_vpad   = $d_elements->{$d_element_nm}->{'vpad'};
		}
	}

	CALCULATE_ERRMSG_POSITION: {

		my $d_element_errmsg_nm = 'errmsg_queue';
		my $d_element_sep_nm    = 'sep';

		my $xpos = $d_elements->{$d_element_sep_nm}->{'e_xpos'};

		my $ypos = $d_elements->{$d_element_sep_nm}->{'e_ypos'} + 
		           $d_elements->{$d_element_sep_nm}->{'e_height'} + 
		           $d_elements->{$d_element_sep_nm}->{'vpad'};

		$d_elements->{$d_element_errmsg_nm}->{'e_xpos'} = $xpos;
		$d_elements->{$d_element_errmsg_nm}->{'e_ypos'} = $ypos;
	}

	CALCULATE_SEARCHBOX_POSITION: {

		my $d_element_top_nm       = 'column_titles';
		my $d_element_searchbox_nm = 'search_box';

		my $xpos = $d_elements->{$d_element_top_nm}->{'e_xpos'} + 10;
		my $ypos = $d_elements->{$d_element_top_nm}->{'e_ypos'} + 10;

		$d_elements->{$d_element_searchbox_nm}->{'e_xpos'} = $xpos;
		$d_elements->{$d_element_searchbox_nm}->{'e_ypos'} = $ypos;
	}

	SET_SEARCHBOX_ENABLED_ZERO: {

		my $d_element_searchbox_nm = 'search_box';

		$d_elements->{$d_element_searchbox_nm}->{'enabled'} = 0;
	}

	foreach my $key (keys %{ $d_elements }) {

		# Initially, fill 'e_contents' with array of lines of SPACE characters.

		$d_elements->{$key}->{'e_contents'} = 
		  $self->generate_blank_e_contents 
		    ({ 'e_width'  => $d_elements->{$key}->{'e_width'}, 
		       'e_height' => $d_elements->{$key}->{'e_height'} });
	}

	return ($d_elements);
}

sub active_d_elements {

	my $self = shift;

	my @active_d_elements;

	foreach my $d_element 
	  (keys %{ $self->{'d_elements'} }) {

		if (exists  $self->{'d_elements'} && 
		    defined $self->{'d_elements'} && 
		      (ref ($self->{'d_elements'}) eq 'HASH') && 
		    exists  $self->{'d_elements'}->{$d_element} && 
		    defined $self->{'d_elements'}->{$d_element} && 
		      (ref ($self->{'d_elements'}->{$d_element}) eq 'HASH') && 
		    exists  $self->{'d_elements'}->{$d_element}->{'enabled'} && 
		    defined $self->{'d_elements'}->{$d_element}->{'enabled'} && 
		           ($self->{'d_elements'}->{$d_element}->{'enabled'} == 1)) {

			push @active_d_elements, $self->{'d_elements'}->{$d_element};
		}
	}

	return (\@active_d_elements);
}

sub c_elements_init {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	# Foreground Colors
	# _________________
	# FG_BLACK
	# FG_BROWN
	# FG_CYAN
	# FG_GRAY
	# FG_BLUE
	# FG_GREEN
	# FG_LIGHTBLUE
	# FG_LIGHTCYAN
	# FG_LIGHTGRAY
	# FG_LIGHTGREEN
	# FG_LIGHTMAGENTA
	# FG_LIGHTRED
	# FG_MAGENTA
	# FG_RED
	# FG_WHITE
	# FG_YELLOW

	# Background Colors
	# _________________
	# BG_BLACK
	# BG_BLUE
	# BG_BROWN
	# BG_CYAN
	# BG_GRAY
	# BG_GREEN
	# BG_LIGHTBLUE
	# BG_LIGHTCYAN
	# BG_LIGHTGRAY
	# BG_LIGHTGREEN
	# BG_LIGHTMAGENTA
	# BG_LIGHTRED
	# BG_MAGENTA
	# BG_RED
	# BG_WHITE
	# BG_YELLOW

	my $c_elements = {

	# COLUMN #0 - COLUMN TITLES 
	'column_titles' => 
	  {'wd'  => $self->{'d_elements'}->{'column_titles'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'column_titles'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'column_titles'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'column_titles'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #1 - OFFSET (HEX) 1 
	'ofs_hex_col1' => 
	  {'wd'  => (($self->{'d_elements'}->{'ofs_hex'}->{'e_width'} - 2) / 2), 
	   'ht'  => $self->{'d_elements'}->{'ofs_hex'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTRED', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #1d - OFFSET (HEX) DIVIDER 
	'ofs_hex_div' => 
	  {'wd'  => '2', 
	   'ht'  => $self->{'d_elements'}->{'ofs_hex'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'ofs_hex'}->{'e_xpos'} + 10), 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'BG_BLACK'] }, 

	# COLUMN #2 - OFFSET (HEX) 2 
	'ofs_hex_col2' => 
	  {'wd'  => (($self->{'d_elements'}->{'ofs_hex'}->{'e_width'} - 2) / 2), 
	   'ht'  => $self->{'d_elements'}->{'ofs_hex'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'ofs_hex'}->{'e_xpos'} + 10 + 2), 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTRED', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #3 - OFFSET (DECIMAL) 1 
	'ofs_dec_col1' => 
	  {'wd'  => (($self->{'d_elements'}->{'ofs_dec'}->{'e_width'} - 2) / 2), 
	   'ht'  => $self->{'d_elements'}->{'ofs_dec'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'ofs_dec'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #3d - OFFSET (DECIMAL) DIVIDER
	'ofs_dec_div' => 
	  {'wd'  => '2', 
	   'ht'  => $self->{'d_elements'}->{'ofs_dec'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'ofs_dec'}->{'e_xpos'} + 8), 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'BG_BLACK'] }, 

	# COLUMN #4 - OFFSET: DECIMAL 2
	'ofs_dec_col2' => 
	  {'wd'  => (($self->{'d_elements'}->{'ofs_dec'}->{'e_width'} - 2) / 2), 
	   'ht'  => $self->{'d_elements'}->{'ofs_dec'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'ofs_dec'}->{'e_xpos'} + 8 + 2), 
	   'y'   => $self->{'d_elements'}->{'ofs_hex'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #5 - HEX DATA (COL 1) 
	'editor_disp_col1' => 
	  {'wd'  => (($self->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4), 
	   'ht'  => $self->{'d_elements'}->{'editor_disp'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'editor_disp'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'editor_disp'}->{'e_ypos'}, 
	   'attr'=> ['FG_YELLOW', 'FOREGROUND_INTENSITY', 'BG_BLACK'], 
	   'rvrs'=> ['FG_BLACK', 'BG_YELLOW'] }, 

	# COLUMN #6 - HEX (HEX COLUMN 2) 
	'editor_disp_col2' => 
	  {'wd'  => (($self->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4), 
	   'ht'  => $self->{'d_elements'}->{'editor_disp'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 10 + 1), 
	   'y'   => $self->{'d_elements'}->{'editor_disp'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'], 
	   'rvrs'=> ['FG_BLACK', 'BG_WHITE'] }, 

	# COLUMN #7 - HEX (HEX COLUMN 3) 
	'editor_disp_col3' => 
	  {'wd'  => (($self->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4), 
	   'ht'  => $self->{'d_elements'}->{'editor_disp'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 10 + 1 + 10 + 1), 
	   'y'   => $self->{'d_elements'}->{'editor_disp'}->{'e_ypos'}, 
	   'attr'=> ['FG_YELLOW', 'FOREGROUND_INTENSITY', 'BG_BLACK'], 
	   'rvrs'=> ['FG_BLACK', 'BG_YELLOW'] }, 

	# COLUMN #8 - HEX (HEX COLUMN 4) 
	'editor_disp_col4' => 
	  {'wd'  => (($self->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4), 
	   'ht'  => $self->{'d_elements'}->{'editor_disp'}->{'e_height'}, 
	   'x'   => ($self->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 10 + 1 + 10 + 1 + 10 + 1), 
	   'y'   => $self->{'d_elements'}->{'editor_disp'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'], 
	   'rvrs'=> ['FG_BLACK', 'BG_WHITE'] }, 

	# COLUMN #9 - CHARACTER DISPLAY 
	'char_disp' => 
	  {'wd'  => $self->{'d_elements'}->{'char_disp'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'char_disp'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'char_disp'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'char_disp'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTMAGENTA', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #10 - LINE NUMBER 
	'line_num' => 
	  {'wd'  => $self->{'d_elements'}->{'line_num'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'line_num'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'line_num'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'line_num'}->{'e_ypos'}, 
	   'attr'=> ['FG_YELLOW', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# COLUMN #11 - SEPERATOR 
	'sep' => 
	  {'wd'  => $self->{'d_elements'}->{'sep'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'sep'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'sep'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'sep'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'BG_BLACK'] }, 

	# DEBUG INFORMATION - ERRMSG_QUEUE
	'errmsg_queue' => 
	  {'wd'  => $self->{'d_elements'}->{'errmsg_queue'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'errmsg_queue'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'errmsg_queue'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'errmsg_queue'}->{'e_ypos'}, 
	   'attr'=> ['FG_YELLOW', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# DISPLAY ELEMENT - SEARCH_BOX
	'search_box' => 
	  {'wd'  => $self->{'d_elements'}->{'search_box'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'search_box'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'search_box'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'search_box'}->{'e_ypos'}, 
	   'attr'=> ['FG_BLACK', 'FOREGROUND_INTENSITY', 'BG_RED'] }, 

	# DEBUG INFORMATION - MOUSE EVENT
	'dbg_mouse_evt' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_mouse_evt'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_mouse_evt'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_mouse_evt'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_mouse_evt'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	'dbg_keybd_evt' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_keybd_evt'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_keybd_evt'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_keybd_evt'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_keybd_evt'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# DEBUG INFORMATION - UNMATCHED EVENT
	'dbg_unmatched_evt' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_unmatched_evt'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_unmatched_evt'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_unmatched_evt'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_unmatched_evt'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	'dbg_curs' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_curs'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_curs'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_curs'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_curs'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# DEBUG INFORMATION - DISPLAY STATE
	'dbg_display' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_display'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_display'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_display'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_display'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	'dbg_count' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_count'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_count'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_count'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_count'}->{'e_ypos'}, 
	   'attr'=> ['FG_WHITE', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }, 

	# DEBUG INFORMATION - CONSOLE STATE
	'dbg_console' => 
	  {'wd'  => $self->{'d_elements'}->{'dbg_console'}->{'e_width'}, 
	   'ht'  => $self->{'d_elements'}->{'dbg_console'}->{'e_height'}, 
	   'x'   => $self->{'d_elements'}->{'dbg_console'}->{'e_xpos'}, 
	   'y'   => $self->{'d_elements'}->{'dbg_console'}->{'e_ypos'}, 
	   'attr'=> ['FG_LIGHTGREEN', 'FOREGROUND_INTENSITY', 'BG_BLACK'] }

	};

	return ($c_elements);
}

sub active_c_elements {

	my $self = shift;

	my @active_c_elements;

	foreach my $d_element 
	  (keys %{ $self->{'d_elements'} }) {

		if (exists  $self->{'d_elements'} && 
		    defined $self->{'d_elements'} && 
		      (ref ($self->{'d_elements'}) eq 'HASH') && 
		    exists  $self->{'d_elements'}->{$d_element} && 
		    defined $self->{'d_elements'}->{$d_element} && 
		      (ref ($self->{'d_elements'}->{$d_element}) eq 'HASH') && 
		    exists  $self->{'d_elements'}->{$d_element}->{'enabled'} && 
		    defined $self->{'d_elements'}->{$d_element}->{'enabled'} && 
		           ($self->{'d_elements'}->{$d_element}->{'enabled'} == 1) &&
		    exists  $self->{'d_elements'}->{$d_element}->{'color'} && 
		    defined $self->{'d_elements'}->{$d_element}->{'color'} && 
		      (ref ($self->{'d_elements'}->{$d_element}->{'color'}) eq 'ARRAY') && 
		(scalar (@{ $self->{'d_elements'}->{$d_element}->{'color'} }) > 0)) {

			foreach my $c_element (@{ $self->{'d_elements'}->{$d_element}->{'color'} }) {

				if (exists  $self->{'c_elements'} && 
				    defined $self->{'c_elements'} && 
				      (ref ($self->{'c_elements'}) eq 'HASH') && 
				    exists  $self->{'c_elements'}->{$c_element} && 
				    defined $self->{'c_elements'}->{$c_element} && 
				      (ref ($self->{'c_elements'}->{$c_element}) eq 'HASH')) {

					push @active_c_elements, $self->{'c_elements'}->{$c_element};
				}
			}
		}
	}

	return (\@active_c_elements);
}

sub generate_blank_e_contents {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to generate_blank_e_contents() failed, argument must be hash reference"; }

	if (! exists  $arg->{'e_width'} || 
	    ! defined $arg->{'e_width'} || 
	             ($arg->{'e_width'} eq '') || 
	           ! ($arg->{'e_width'} =~ /^\d+?$/)) 
		{ die "Call to generate_blank_e_contents() failed, value associated w/ key 'e_width' is undef/empty string/not of correct type"; }

	if (! exists  $arg->{'e_height'} || 
	    ! defined $arg->{'e_height'} || 
	             ($arg->{'e_height'} eq '') || 
	           ! ($arg->{'e_height'} =~ /^\d+?$/)) 
		{ die "Call to generate_blank_e_contents() failed, value associated w/ key 'e_height' is undef/empty string/not of correct type"; }

	my $e_contents = [];
	foreach my $lnum (1 .. $arg->{'e_height'}) 
		{ push @{ $e_contents }, (' ' x $arg->{'e_width'}); }

	return ($e_contents);
}

sub generate_blank_display {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to generate_blank_e_contents() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_width'} || 
	    ! defined $arg->{'d_width'} || 
	             ($arg->{'d_width'} eq '') || 
	           ! ($arg->{'d_width'} =~ /^\d+?$/)) 
		{ die "Call to generate_blank_display() failed, value associated w/ key 'd_width' must be one or more digits"; }

	if (! exists  $arg->{'d_height'} || 
	    ! defined $arg->{'d_height'} || 
	             ($arg->{'d_height'} eq '') || 
	           ! ($arg->{'d_height'} =~ /^\d+?$/)) 
		{ die "Call to generate_blank_display() failed, value associated w/ key 'd_height' must be one or more digits"; }

	# Initialize array of display lines with blank spaces (an empty display).

	my $blank_dsp = [];
	for my $ln (1 .. $arg->{'d_height'}) 
		{ push @{ $blank_dsp }, (' ' x $arg->{'d_width'}); }

	return ($blank_dsp);
}

sub generate_editor_display {

	my $self = shift;

	my $objDebug = $self->{'obj'}->{'debug'};

	my $display = 
	  $self->generate_blank_display 
	    ({ 'd_width'  => $self->{'d_width'}, 
	       'd_height' => $self->{'d_height'} });

	# Add each display element to array of display lines.

	DISPLAY_ELEMENTS: 
	  foreach my $nm 
	    ('column_titles', 
	     'ofs_hex', 
	     'ofs_dec', 
	     'editor_disp', 
	     'char_disp', 
	     'line_num', 
	     'sep', 
	     'dbg_mouse_evt', 
	     'dbg_keybd_evt', 
	     'dbg_unmatched_evt', 
	     'dbg_curs', 
	     'dbg_display', 
	     'dbg_count', 
	     'dbg_console', 
	     'errmsg_queue', 
	     'search_box') {

		if (! ($self->{'d_elements'}->{$nm}->{'enabled'} == 1)) 
			{ next DISPLAY_ELEMENTS; }

		my $d_el = $self->{'d_elements'}->{$nm};

		my $e_xpos     = $d_el->{'e_xpos'};
		my $e_ypos     = $d_el->{'e_ypos'};
		my $e_width    = $d_el->{'e_width'};
		my $e_height   = $d_el->{'e_height'};
		my $e_contents = $d_el->{'e_contents'};
		my $e_changed  = $d_el->{'e_changed'};
		my $subref     = $d_el->{'subref'};

		# Call subroutine (by reference) to generate lines of display element, 
		# Check return value to for correct number of lines, 
		# Store return value in 'd_element' hash as value associated w/ key 'e_contents'.

		my $rv = &{ $subref };
		if (defined $rv            && 
		    (ref ($rv) eq 'ARRAY') && 
		    (scalar (@{ $rv }) == $e_height)) {

			$d_el->{'e_contents'} = $rv;
		}

		# Line by line, substitute strings from 'e_contents' into the larger strings held in 'display'.

		foreach my $d_idx ($e_ypos .. (($e_ypos + $e_height) - 1)) {

			# If length of string in e_contents is less than e_width, pad the end with spaces.

			my $e_idx = ($d_idx - $e_ypos);
			if (length ($d_el->{'e_contents'}->[$e_idx]) < $e_width) {

				warn "Display element '" . $nm . "', " . 
				     "e_contents indice '" . $e_idx . "' " . 
				     "holds string w/ length '" . length ($d_el->{'e_contents'}->[$e_idx]) . "' " . 
				     "(less than e_width: '" . $e_width . "')";

				$d_el->{'e_contents'}->[$e_idx] .= 
				  (' ' x ($e_width - (length ($d_el->{'e_contents'}->[$e_idx]))));
			}

			# Extract string from 'display' to be replaced by string from 'e_content'.

			my $d_str = substr $display->[$d_idx], $e_xpos, $e_width;
			my $e_str = $d_el->{'e_contents'}->[$e_idx];

			# Compare substring extracted from 'display' string against string from 'e_content':
			#   - If they're identical, no substitution is made.
			#   - If they're mismatched, make substitution.

			if (! ($d_str eq $e_str)) {

				# substr EXPR, OFFSET, LENGTH, REPLACEMENT
				#
				#   Specify a replacement string as the 4th argument. This allows you to
				#   replace parts of the EXPR and return what was there before in one 
				#   operation, just as you can with splice().

				my $str_repl = 
				  substr $display->[$d_idx], 
				         $e_xpos, 
				         length ($d_el->{'e_contents'}->[$e_idx]), 
				         $d_el->{'e_contents'}->[$e_idx];

				if ((length ($display->[$d_idx])) < $self->{'d_width'}) {

					warn "Display line indice '" . $d_idx . "' " . 
					     "holds string w/ length '" . length ($display->[$d_idx]) . "' " . 
					     "(str len less than d_width '" . $self->{'d_width'} . "')";

					$display->[$d_idx] .= (' ' x ($self->{'d_width'} - (length ($display->[$d_idx]))));
				}
			}
		}
	}

	# Return reference to array of display lines to caller.

	return ($display);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::Display (ZHex/Display.pm) - Display Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::Display module defines functions which generate, update, and 
refresh the console display.

Specifically, the ZHex::Display module functions provide for:

    Addition/removal of individual display elements.
    Resizing the display.
    Increasing/decreasing the number of rows displayed in the editor.
    Enabling/disabling the display of debugging information.

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objDisplay = $self->{'obj'}->{'display'};
    $objDisplay->padding_set ('dsp_ypad' => 2, 'dsp_xpad' => 2);

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 active_c_elements
Method active_c_elements()...
= cut

=head2 active_d_elements
Method active_d_elements()...
= cut

=head2 c_elements_init
Method c_elements_init()...
= cut

=head2 c_elements_set
Method c_elements_set()...
= cut

=head2 d_elements_init
Method d_elements_init()...
= cut

=head2 d_elements_set
Method d_elements_set()...
= cut

=head2 d_elements_tbl
Method d_elements_tbl()...
= cut

=head2 dimensions_set
Method dimensions_set()...
= cut

=head2 dsp_prev_init
Method dsp_prev_init()...
= cut

=head2 dsp_prev_set
Method dsp_prev_set()...
= cut

=head2 dsp_set
Method dsp_set()...
= cut

=head2 generate_blank_display
Method generate_blank_display()...
= cut

=head2 generate_blank_e_contents
Method generate_blank_e_contents()...
= cut

=head2 generate_editor_display
Method generate_editor_display()...
= cut

=head2 init
Method init()...
= cut

=head2 padding_set
Method padding_set()...
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

