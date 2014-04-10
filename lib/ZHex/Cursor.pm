#!/usr/bin/perl

package ZHex::Cursor;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     obj_init 
     $VERS
     CURS_CTXT_LINE 
     CURS_CTXT_WORD 
     CURS_CTXT_BYTE 
     CURS_CTXT_INSR 
     CURS_CTXT 
     CURS_POS
     EDT_CTXT_DEFAULT 
     EDT_CTXT_INSERT 
     EDT_CTXT_SEARCH 
     SZ_WORD 
     SZ_LINE 
     SZ_COLUMN);

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

	# Declared here. Set via accessor methods.

	$self->{'sz_word'}   = '';   # Declared here. Set via accessor method: set_sz_word().
	$self->{'sz_line'}   = '';   # Declared here. Set via accessor method: set_sz_line().
	$self->{'sz_column'} = '';   # Declared here. Set via accessor method: set_sz_column().

	$self->{'curs_ctxt'} = '';   # Declared here. Set via accessor method: set_curs_ctxt().
	$self->{'curs_pos'}  = '';   # Declared here. Set via accessor method: set_curs_pos().

	# Initialized here, used/updated by methods within this module.

	$self->{'curs_coords'} = [];      # Cursor coordinates.
	$self->{'ct_display_curs'} = 0;   # Counter, used for debugging information display.

	return (1);
}

sub register_evt_callbacks {

	my $self = shift;

	my $objCharMap   = $self->{'obj'}->{'charmap'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEvent     = $self->{'obj'}->{'event'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_BEG', 
	    'evt_cb'   => sub {
			$self->set_curs_pos 
			  ({'curs_pos' => 0});
			$objEditor->set_edt_pos 
			  ({'edt_pos' => 0}); }, 
	     'evt' => [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CIRCUMFLEX ACCENT'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_END', 
	    'evt_cb'   => sub { 
			$self->set_curs_ctxt 
			  ({'curs_ctxt' => 2});
			$self->set_curs_pos 
			  ({'curs_pos' => ($objFile->file_len() - 1)});
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'} }); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'DOLLAR SIGN'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'INCR_CURS_CTXT', 
	    'evt_cb'   => sub { $self->curs_ctxt_incr(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CARRIAGE RETURN (CR)'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'DECR_CURS_CTXT', 
	    'evt_cb'   => sub { $self->curs_ctxt_decr(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'ESCAPE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_FORWARD', 
	    'evt_cb'   => sub { 
			$self->curs_mv_fwd
			  ({'file_len' => $objFile->file_len()});
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); 
	                }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 32 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' =>  0 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_BACK', 
	    'evt_cb'   => sub { 
			$self->curs_mv_back();
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 48 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 16 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_UP', 
	    'evt_cb'   => sub { 
			$self->curs_mv_up();
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  38,     # 3
			   '4' =>  72,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  38,     # 3
			   '4' =>  72,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_DOWN', 
	    'evt_cb'   => sub { 
	                $self->curs_mv_down
			  ({'file_len' => $objFile->file_len()});
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  40,     # 3
			   '4' =>  80,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  40,     # 3
			   '4' =>  80,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_LEFT', 
	    'evt_cb'   => sub { 
			$self->curs_mv_left();
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER H'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  37,     # 3
			   '4' =>  75,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  37,     # 3
			   '4' =>  75,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_RIGHT', 
	    'evt_cb'   => sub { 
			$self->curs_mv_right
			  ({'file_len' => $objFile->file_len()});
			$objEditor->dsp_pos_adjust 
			  ({'curs_pos' => $self->{'curs_pos'}}); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER L'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  39,     # 3
			   '4' =>  77,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  39,     # 3
			   '4' =>  77,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	return (1);
}

#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   set_curs_ctxt()	Member variable accessor method.
#   set_curs_pos()	Member variable accessor method.
#   set_sz_word()	Member variable accessor method.
#   set_sz_line()	Member variable accessor method.
#   set_sz_column()	Member variable accessor method.

sub set_curs_ctxt {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_curs_ctxt() failed, argument must be hash reference"; }

	if (! exists  $arg->{'curs_ctxt'} || 
	    ! defined $arg->{'curs_ctxt'} || 
	          (! ($arg->{'curs_ctxt'} == CURS_CTXT_LINE) &&
	           ! ($arg->{'curs_ctxt'} == CURS_CTXT_WORD) && 
	           ! ($arg->{'curs_ctxt'} == CURS_CTXT_BYTE) && 
	           ! ($arg->{'curs_ctxt'} == CURS_CTXT_INSR))) {

		die "Call to set_curs_ctxt() failed, value of key 'curs_ctxt' must be one of: " . 
		    (join (', ', (CURS_CTXT_LINE, 
		                  CURS_CTXT_WORD, 
		                  CURS_CTXT_BYTE, 
		                  CURS_CTXT_INSR)));
	}
	$self->{'curs_ctxt'} = $arg->{'curs_ctxt'};

	return (1);
}

sub set_curs_pos {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_curs_pos() failed, argument must be hash reference"; }

	if (! exists  $arg->{'curs_pos'} || 
	    ! defined $arg->{'curs_pos'} || 
	           ! ($arg->{'curs_pos'} =~ /^\d+?$/)) 
		{ die "Call to set_curs_pos() failed, value of key 'curs_pos' must be numeric"; }

	$self->{'curs_pos'} = $arg->{'curs_pos'};

	return (1);
}

sub set_sz_word {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_sz_word() failed, argument must be hash reference"; }

	if (! exists  $arg->{'sz_word'} || 
	    ! defined $arg->{'sz_word'} || 
	           ! ($arg->{'sz_word'} =~ /^\d+?$/)) 
		{ die "Call to set_sz_word() failed, value of key 'sz_word' must be numeric"; }

	$self->{'sz_word'} = $arg->{'sz_word'};

	return (1);
}

sub set_sz_line {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_sz_line() failed, argument must be hash reference"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to set_sz_line() failed, value of key 'sz_line' must be numeric"; }

	$self->{'sz_line'} = $arg->{'sz_line'};

	return (1);
}

sub set_sz_column {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_sz_column() failed, argument must be hash reference"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to set_sz_column() failed, value of key 'sz_column' must be numeric"; }

	$self->{'sz_column'} = $arg->{'sz_column'};

	return (1);
}

# Cursor Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   dsp_coord()			...
#   curs_display()		Update display console to reflect the present cursor position.
#   calc_coord_array()		...
#   comp_coord_arrays()		...
#   calc_row_offset()		...
#   calc_row()			...
#   align_word_boundary()	...
#   align_line_boundary()	...

sub dsp_coord {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dsp_coord() failed, argument must be hash reference"; }

	if (! exists  $arg->{'curs_pos'} || 
	    ! defined $arg->{'curs_pos'} || 
	           ! ($arg->{'curs_pos'} =~ /^\d+?$/)) 
		{ die "Call to dsp_coord() failed, value associated w/ key 'curs_pos' must be one or more digits"; }

	if (! exists  $arg->{'edt_pos'} || 
	    ! defined $arg->{'edt_pos'} || 
	           ! ($arg->{'edt_pos'} =~ /^\d+?$/)) 
		{ die "Call to dsp_coord() failed, value associated w/ key 'edt_pos' must be one or more digits"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d+?$/)) 
		{ die "Call to dsp_coord() failed, value associated w/ key 'dsp_xpad' must be one or more digits"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d+?$/)) 
		{ die "Call to dsp_coord() failed, value associated w/ key 'dsp_ypad' must be one or more digits"; }

	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	if ($arg->{'curs_pos'} < $arg->{'edt_pos'}) {
		
		die "#1 Call to dsp_coord() failed: curs_pos='" . $arg->{'curs_pos'} . "'";
	}

	if ($arg->{'curs_pos'} > ($arg->{'edt_pos'} + ($objEditor->{'sz_line'} * $objEditor->{'sz_column'}))) {

		# $objDebug->errmsg ("c) dsp_coord: curs_pos='" . $arg->{'curs_pos'} . "'.");
		# $objDebug->errmsg ("c) dsp_coord: curs_pos='" . $arg->{'curs_pos'} . "'.");
		# $objDebug->errmsg ("c) dsp_coord: curs_pos='" . $arg->{'curs_pos'} . "'.");
		die "#2 Call to dsp_coord() failed: curs_pos='" . $arg->{'curs_pos'} . "'";
	}

	my $cofs = $arg->{'curs_pos'} - $objEditor->{'edt_pos'};

	my $xofs = 0;
	my $yofs = 0;
	if ($cofs < $objEditor->{'sz_line'}) {

		$xofs = $cofs;
	}
	else {

		$yofs = ($cofs / $objEditor->{'sz_line'});
		if ($yofs =~ s/\.\d+?$//) {

			$xofs = ($cofs - ($yofs * $objEditor->{'sz_line'}));
		}
	}

	my $xpos;
	if ($xofs >= 12) {

		$xpos = 
		  ($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 2 + 1 + 1 + 1 + 
		   ((($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) * 3) + 
		   (($xofs - 12) * 2));
	}
	elsif ($xofs >= 8) {

		$xpos = 
		  ($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 2 + 1 + 1 + 
		   ((($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) * 2) + 
		   (($xofs - 8) * 2));
	}
	elsif ($xofs >= 4) {

		$xpos = 
		  ($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 2 + 1 + 
		   ((($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) * 1) + 
		   (($xofs - 4) * 2));
	}
	else {

		$xpos = 
		  ($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_xpos'} + 2 +
		   ((($objDisplay->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) * 0) + 
		   (($xofs - 0) * 2));
	}

	my $ypos = 
	     $objDisplay->{'d_elements'}->{'editor_disp'}->{'e_ypos'} + 
	     $yofs;

	return ($xpos, $ypos);
}

sub curs_display {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to colorize_display() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_display() failed, value of key 'dsp_xpad' must be numeric"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d\d?\d?$/)) 
		{ die "Call to colorize_display() failed, value of key 'dsp_ypad' must be numeric"; }

	if (! exists  $arg->{'force'} || 
	    ! defined $arg->{'force'} || 
	           ! ($arg->{'force'} =~ /^[01]$/)) 
		{ die "Call to colorize_display() failed, value of key 'force' must be numeric [0|1]"; }

	my $objConsole = $self->{'obj'}->{'console'};
	my $objDebug   = $self->{'obj'}->{'debug'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	# Calculate the new X,Y coordinates of cursor position within 
	# the editor display.

	# $objDebug->errmsg ("curs_display: curs_pos='" . $self->{'curs_pos'} . "'.");

	my $new_coords = 
	  $self->calc_coord_array 
	    ({ 'curs_ctxt' => $self->{'curs_ctxt'}, 
	       'curs_pos'  => $self->{'curs_pos'}, 
	       'edt_pos'   => $objEditor->{'edt_pos'}, 
	       'dsp_xpad'  => $arg->{'dsp_xpad'}, 
	       'dsp_ypad'  => $arg->{'dsp_ypad'} });

	# Compare old cursor position with new cursor position: 
	#
	#   - If the coordinates have not changed: do not update display.
	#   - If the coordinates have changed: update display.

	my $match;
	my $c_elements;
	if (defined $self->{'curs_coords'}) {

		$match = 
		  $self->comp_coord_arrays 
		    ({ 'array1' => $self->{'curs_coords'}, 
		       'array2' => $new_coords });

		if (! ($match == 1)) {

			# Turn off reverse highlighting on old cursor position.

			foreach my $coords (@{ $self->{'curs_coords'} }) {

				my ($xc, $yc) = (@{ $coords });

				$objConsole->colorize_reverse 
				  ({ 'c_elements' => $objDisplay->active_c_elements(), 
				     'xc'         => ($xc + $arg->{'dsp_xpad'}), 
				     'yc'         => ($yc + $arg->{'dsp_ypad'}), 
				     'width'      => 2, 
				     'action'     => 'off', 
				     'dsp_xpad'   => $arg->{'dsp_xpad'}, 
				     'dsp_ypad'   => $arg->{'dsp_ypad'} });
			}
		}
	}

	if (! (defined $self->{'curs_coords'}) || 
	      (defined $self->{'curs_coords'} && ! ($match == 1)) ||
	      ($arg->{'force'} == 1)) {

		# Turn on reverse highlighting on new cursor position.

		foreach my $coords (@{ $new_coords }) {

			my ($xc, $yc) = (@{ $coords });

			if (! defined $xc || 
			           ! ($xc =~ /^\d+?$/)) {

				die "Woohaa, got you all in check: coords='" . (scalar (@{ $coords })) . "'";
			}
			else {

				# $objDebug->errmsg ("xc='" . $xc . "', yc='" . $yc . "'.");
			}

			$objConsole->colorize_reverse 
			  ({ 'c_elements' => $objDisplay->active_c_elements(), 
			     'xc'         => ($xc + $arg->{'dsp_xpad'}),         # <--- Use of uninitialized value $xc in addition (+) at ZHex/Cursor.pm line 239.
			     'yc'         => ($yc + $arg->{'dsp_ypad'}), 
			     'width'      => 2, 
			     'action'     => 'on', 
			     'dsp_xpad'   => $arg->{'dsp_xpad'}, 
			     'dsp_ypad'   => $arg->{'dsp_ypad'} });
		}
	}

	# Store current cursor position coordinates for next pass through.

	if ($self->{'curs_ctxt'} == 3) 
	     { $self->{'curs_coords'} = []; }
	else { $self->{'curs_coords'} = $new_coords; }

	$self->{'ct_display_curs'}++;   # Count number of display updates.

	return (1);
}

# calc_coord_array() args: 'curs_ctxt', 'curs_pos', 'edt_pos', 'dsp_xpad', 'dsp_ypad'.

sub calc_coord_array {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to calc_coord_array() failed, argument must be hash reference"; }

	if (! exists  $arg->{'curs_ctxt'} || 
	    ! defined $arg->{'curs_ctxt'} || 
	           ! ($arg->{'curs_ctxt'} =~ /^\d+?$/)) 
		{ die "Call to calc_coord_array() failed, value associated w/ key 'curs_ctxt' must be one or more digits"; }

	if (! exists  $arg->{'curs_pos'} || 
	    ! defined $arg->{'curs_pos'} || 
	           ! ($arg->{'curs_pos'} =~ /^\d+?$/)) 
		{ die "Call to calc_coord_array() failed, value associated w/ key 'curs_pos' must be one or more digits"; }

	if (! exists  $arg->{'edt_pos'} || 
	    ! defined $arg->{'edt_pos'} || 
	           ! ($arg->{'edt_pos'} =~ /^\d+?$/)) 
		{ die "Call to calc_coord_array() failed, value associated w/ key 'edt_pos' must be one or more digits"; }

	if (! exists  $arg->{'dsp_xpad'} || 
	    ! defined $arg->{'dsp_xpad'} || 
	           ! ($arg->{'dsp_xpad'} =~ /^\d+?$/)) 
		{ die "Call to calc_coord_array() failed, value associated w/ key 'dsp_xpad' must be one or more digits"; }

	if (! exists  $arg->{'dsp_ypad'} || 
	    ! defined $arg->{'dsp_ypad'} || 
	           ! ($arg->{'dsp_ypad'} =~ /^\d+?$/)) 
		{ die "Call to calc_coord_array() failed, value associated w/ key 'dsp_ypad' must be one or more digits"; }

	my $objDebug  = $self->{'obj'}->{'debug'};
	my $objEditor = $self->{'obj'}->{'editor'};

	# $objDebug->errmsg ("calc_coord_array: curs_pos='" . $arg->{'curs_pos'} . "'.");

	# Calculate the new X,Y coordinates of cursor position within the editor display.

	my @curs_coords;
	if ($arg->{'curs_ctxt'} == 0) {

		for my $pos ($arg->{'curs_pos'} .. ($arg->{'curs_pos'} + ($objEditor->{'sz_line'} - 1))) {

			push @curs_coords, 
			       \@{ [
			       $self->dsp_coord 
			         ({ 'curs_pos' => $pos, 
			            'edt_pos'  => $arg->{'edt_pos'}, 
			            'dsp_ypad' => $arg->{'dsp_xpad'}, 
			            'dsp_xpad' => $arg->{'dsp_ypad'} }) ] };
		}
	}
	elsif ($arg->{'curs_ctxt'} == 1) {

		for my $pos ($arg->{'curs_pos'} .. ($arg->{'curs_pos'} + ($objEditor->{'sz_word'} - 1))) {

			push @curs_coords, 
			       \@{ [
			       $self->dsp_coord 
			         ({ 'curs_pos' => $pos, 
			            'edt_pos'  => $arg->{'edt_pos'}, 
			            'dsp_ypad' => $arg->{'dsp_xpad'}, 
			            'dsp_xpad' => $arg->{'dsp_ypad'} }) ] };
		}
	}
	elsif ($arg->{'curs_ctxt'} == 2) {

		push @curs_coords, 
		       \@{ [
		       $self->dsp_coord 
		         ({ 'curs_pos' => $arg->{'curs_pos'}, 
			    'edt_pos'  => $arg->{'edt_pos'}, 
			    'dsp_ypad' => $arg->{'dsp_xpad'}, 
			    'dsp_xpad' => $arg->{'dsp_ypad'} }) ] };
	}
	elsif ($arg->{'curs_ctxt'} > 3) {

		die "Cursor context key/value pair outside of acceptable range of values: [0, 1, 2, 3]";
	}

	return (\@curs_coords);
}

sub comp_coord_arrays {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to comp_coord_arrays() failed, argument must be hash reference"; }

	if (! exists  $arg->{'array1'} || 
	    ! defined $arg->{'array1'} || 
	      ! (ref ($arg->{'array1'}) eq 'ARRAY')) 
		{ die "Call to comp_coord_arrays() failed, value associated w/ key 'array1' must be array reference"; }

	if (! exists  $arg->{'array2'} || 
	    ! defined $arg->{'array2'} || 
	      ! (ref ($arg->{'array2'}) eq 'ARRAY')) 
		{ die "Call to comp_coord_arrays() failed, value associated w/ key 'array2' must be array reference"; }

	# Compare two arrays (passed by reference):
	#   Each array (array1 and array2) contains a list of array references:
	#     Evaluates 'true' if all of the values stored in the referenced arrays match.

	# Test both arguments for definedness and correct type.

	if (! defined $arg->{'array1'} || 
	    ! (ref ($arg->{'array1'}) eq 'ARRAY') || 
	    ! defined $arg->{'array2'} || 
	    ! (ref ($arg->{'array2'}) eq 'ARRAY')) 
		{ return (0); }

	# Test both arguments to verify both have the same number of elements defined.

	if (! ((scalar (@{ $arg->{'array1'} })) == (scalar (@{ $arg->{'array2'} })))) 
		{ return (0); }

	# Compare the values in each array reference contained within both arguments.

	for my $idx (0 .. (scalar (@{ $arg->{'array1'} }) - 1)) {

		my ($xpos1, $ypos1) = @{ $arg->{'array1'}->[$idx] };
		my ($xpos2, $ypos2) = @{ $arg->{'array2'}->[$idx] };

		if (! ($xpos1 == $xpos2) || 
		    ! ($ypos1 == $ypos2))
		     { return (0); }
	}

	return (1);
}

sub calc_row_offset {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to calc_row_offset() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq "") || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to calc_row_offset() failed, value associated w/ key 'pos' must be one or more digits"; }

	if ($arg->{'pos'} == 0) 
		{ return (0); }

	my $row = ($arg->{'pos'} / $self->{'sz_line'});
	if ($row =~ s/\.\d.*$//) {

		my $ofs = $arg->{'pos'} - ($row * $self->{'sz_line'});
		return ($ofs);
	}
	else {

		return (0);
	}
}

sub align_word_boundary {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to align_line_boundary() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq "") || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to align_line_boundary() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (($arg->{'pos'} >= 0) &&
	    ($arg->{'pos'} < $self->{'sz_word'})) {

		return (0);
	}

	my $word  = ($arg->{'pos'} / $self->{'sz_word'});
	$word     =~ s/\.\d.*$//;
	my $bound = ($word * $self->{'sz_word'});

	return ($bound);
}

sub align_line_boundary {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to align_line_boundary() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq "") || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to align_line_boundary() failed, value associated w/ key 'pos' must be one or more digits"; }

	if ($arg->{'pos'} < 0) {

		return (undef);
	}
	elsif (($arg->{'pos'} >= 0) &&
	       ($arg->{'pos'} < $self->{'sz_line'})) {

		return (0);
	}

	my $line = ($arg->{'pos'} / $self->{'sz_line'});
	$line =~ s/\.\d.*$//;
	my $bound = ($line * $self->{'sz_line'});

	return ($bound);
}

# Cursor Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   curs_mv_back()		Move cursor backward one column/character/row.
#   curs_mv_fwd()		Move cursor forward  one column/character/row.
#   curs_move_up()		Move cursor up       one row.
#   curs_move_down()		Move cursor down     one row.
#   curs_move_left()		Move cursor left     one column/character.
#   curs_move_right()		Move cursor right    one column/character.
#   curs_ctxt_decr()		Adjust cursor context, decrement value.
#   curs_ctxt_incr()		Adjust cursor context, increment value.
#   curs_adjust()		...

sub curs_mv_back {

	my $self = shift;

	if (($self->{'curs_ctxt'} == 0) && 
	    ($self->{'curs_pos'} >= $self->{'sz_line'})) {

		$self->{'curs_pos'} -= $self->{'sz_line'};
	}
	elsif (($self->{'curs_ctxt'} == 1) && 
	       ($self->{'curs_pos'} >= $self->{'sz_word'})) {

		$self->{'curs_pos'} -= $self->{'sz_word'};
	}
	elsif (($self->{'curs_ctxt'} == 2) && 
	       ($self->{'curs_pos'} >= 1)) {

		$self->{'curs_pos'} -= 1;
	}

	return (1);
}

sub curs_mv_fwd {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to curs_mv_fwd() failed, argument must be hash reference"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq "") || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to curs_mv_fwd() failed, value associated w/ key 'file_len' must be one or more digits"; }

	if (($self->{'curs_ctxt'} == 0) && 
	    ($self->{'curs_pos'} < ($arg->{'file_len'} - $self->{'sz_line'} - 1))) {

		$self->{'curs_pos'} += $self->{'sz_line'};
	}
	elsif (($self->{'curs_ctxt'} == 1) &&
	       ($self->{'curs_pos'} < ($arg->{'file_len'} - $self->{'sz_word'} - 1))) {

		$self->{'curs_pos'} += $self->{'sz_word'};
	}
	elsif (($self->{'curs_ctxt'} == 2) &&
	       ($self->{'curs_pos'} < ($arg->{'file_len'} - 1))) {

		$self->{'curs_pos'} += 1;
	}

	return (1);
}

sub curs_mv_up {

	my $self = shift;

	if ($self->{'curs_ctxt'} > 2) 
		{ return (undef); }

	if ($self->{'curs_pos'} >= $self->{'sz_line'}) {

		$self->{'curs_pos'} -= $self->{'sz_line'};
	}
 
	return (1);
}

sub curs_mv_down {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to curs_mv_down() failed, argument must be hash reference"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq "") || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to curs_mv_down() failed, value associated w/ key 'file_len' must be one or more digits"; }

	# Error here when scrolling to last line, last byte...

	if ((($self->{'curs_ctxt'} == 0)  || 
	     ($self->{'curs_ctxt'} == 1)  || 
	     ($self->{'curs_ctxt'} == 2)) && 
	     ($self->{'curs_pos'} < ($arg->{'file_len'} - $self->{'sz_line'}))) {

		$self->{'curs_pos'} += $self->{'sz_line'};
	}
	
	return (1);
}

sub curs_mv_left {

	my $self = shift;

	my $ofs = $self->calc_row_offset ({ 'pos' => $self->{'curs_pos'} });

	if ($self->{'curs_ctxt'} < 1) {

		return (undef);
	}
	if (($self->{'curs_ctxt'} == 1) && 
	    ($ofs >= $self->{'sz_word'})) {

		$self->{'curs_pos'} -= $self->{'sz_word'};
	}
	elsif (($self->{'curs_ctxt'} == 2) && 
	       ($ofs >= 1)) {

		$self->{'curs_pos'} -= 1;
	}
	elsif ($self->{'curs_ctxt'} > 2) {

		return (undef);
	}

	return (1);
}

sub curs_mv_right {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to curs_mv_right() failed, argument must be hash reference"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq "") || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to curs_mv_right() failed, value associated w/ key 'file_len' must be one or more digits"; }

	my $ofs = $self->calc_row_offset ({ 'pos' => $self->{'curs_pos'} });

	if ($self->{'curs_ctxt'} < 1) {

		return (undef);
	}
	if (($self->{'curs_ctxt'} == 1) && 
	    ($ofs < 12)                 && 
	    ($self->{'curs_pos'} <= (($arg->{'file_len'} - $self->{'sz_word'}) - 1))) {

		# Error here, when moving cursor right at end of file. Cursor will highlight partial word at end...

		$self->{'curs_pos'} += $self->{'sz_word'};
	}
	elsif (($self->{'curs_ctxt'} == 2) && 
	       ($ofs < 15)                 && 
	       ($self->{'curs_pos'} <= (($arg->{'file_len'} - 1) - 1))) {

		$self->{'curs_pos'} += 1;
	}
	elsif ($self->{'curs_ctxt'} > 2) {

		return (undef);
	}

	return (1);
}

sub curs_ctxt_decr {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if ($self->{'curs_ctxt'} < 1)       # Cursor context 0 (16 byte/full line).
		{ return (undef); }

	elsif ($self->{'curs_ctxt'} == 1)   # Cursor context 1 (4 byte/word).
		{ $self->{'curs_pos'} = $self->align_line_boundary ({ 'pos' => $self->{'curs_pos'} }); }

	elsif ($self->{'curs_ctxt'} == 2)   # Cursor context 2 (1 byte).
		{ $self->{'curs_pos'} = $self->align_word_boundary ({ 'pos' => $self->{'curs_pos'} }); }

	elsif ($self->{'curs_ctxt'} == 3)   # Cursor context 3 (INSERT mode).
		{ $objConsole->w32cons_cursor_invisible();       # Hide Win32 console cursor.
		  $objConsole->w32cons_cursor_move ({ 'xpos' => 0, 'ypos' => 0 }); }   # Move Win32 console cursor to top/left corner of display console.

	$self->{'curs_ctxt'}--;             # Decrease cursor context.

	return (1);
}

sub curs_ctxt_incr {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	if ($self->{'curs_ctxt'} > 2) 
		{ return (undef); }

	$self->{'curs_ctxt'}++;   # Increase cursor context.

	if ($self->{'curs_ctxt'} == 3) {

		# 1) Set the Win32 console cursor visible.
		# 2) Move the Win32 console cursor to 'curs_pos'.

		$objConsole->w32cons_cursor_visible();

		my ($xpos, $ypos) = 
		  $self->dsp_coord 
		    ({ 'curs_pos' => $self->{'curs_pos'}, 
		       'edt_pos'  => $objEditor->{'edt_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		$objConsole->w32cons_cursor_move 
		  ({ 'xpos' => $xpos, 
		     'ypos' => $ypos });

		# Switch editor context to EDT_CTXT_INSERT.

		$objEditor->{'edt_ctxt'} = EDT_CTXT_INSERT;
	}

	return (1);
}

sub curs_adjust {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to curs_adjust() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_pos'} || 
	    ! defined $arg->{'edt_pos'} || 
	             ($arg->{'edt_pos'} eq '') || 
	           ! ($arg->{'edt_pos'} =~ /^\d+?$/)) 
		{ die "Call to curs_adjust() failed, value associated w/ key 'edt_pos' must be one or more digits"; }

	# If cursor is OOB: update cursor position [below bottom line in editor display].

	while ($self->{'curs_pos'} >= 
	         ($arg->{'edt_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}))) 
		{ $self->{'curs_pos'} -= $self->{'sz_line'}; }

	# If cursor is OOB: update cursor position [above top line in editor display].

	while ($self->{'curs_pos'} < $arg->{'edt_pos'}) 
		{ $self->{'curs_pos'} += $self->{'sz_line'}; }

	# If cursor is OOB: update cursor position [below bottom line in editor display, AGAIN???].

	while (($self->{'curs_ctxt'} == 0) && 
	       ($self->{'curs_pos'} > ($arg->{'edt_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}) - $self->{'sz_line'}))) 
		{ $self->{'curs_pos'} -= $self->{'sz_line'}; }

	while ((($self->{'curs_ctxt'} == 1)  || 
	        ($self->{'curs_ctxt'} == 2)) && 
	        ($self->{'curs_pos'} > ($arg->{'edt_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}) - 1))) 
		{ $self->{'curs_pos'} -= $self->{'sz_line'}; }

	# If cursor is OOB: update cursor position [above top line in editor display, AGAIN???].

	while ($self->{'curs_pos'} < $arg->{'edt_pos'}) 
		{ $self->{'curs_pos'} += $self->{'sz_line'}; }

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::Cursor (ZHex/Cursor.pm) - Cursor Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::Cursor module defines functions which provide for the cursor 
which appears within the hex editor display.

Specifically, the ZHex::Cursor module defines functions which allow for:

    Movement of the cursor within the editor display (via keystrokes 
    or mouse clicks).

    Updating the cursor position in response to scrolling events (or any 
    event which changes the position of the editor display within the 
    file being edited).

    Changing the cursor appearance and behavior in response to the 
    context in which the hex editor is operating.

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objCursor = $self->{'obj'}->{'cursor'};
    $objCursor->curs_mv_right();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 set_curs_pos
Method set_curs_pos()...
= cut

=head2 set_curs_ctxt
Method set_curs_ctxt()...
= cut

=head2 set_sz_word
Method set_sz_word()...
= cut

=head2 set_sz_line
Method set_sz_line()...
= cut

=head2 set_sz_column
Method set_sz_column()...
= cut

=head2 curs_adjust
Method curs_adjust()...
= cut

=head2 align_line_boundary
Method align_line_boundary()...
= cut

=head2 align_word_boundary
Method align_word_boundary()...
= cut

=head2 calc_coord_array
Method calc_coord_array()...
= cut

=head2 calc_row
Method calc_row()...
= cut

=head2 calc_row_offset
Method calc_row_offset()...
= cut

=head2 comp_coord_arrays
Method comp_coord_arrays()...
= cut

=head2 curs_ctxt_decr
Method curs_ctxt_decr()...
= cut

=head2 curs_ctxt_incr
Method curs_ctxt_incr()...
= cut

=head2 curs_display
Method curs_display()...
= cut

=head2 curs_mv_back
Method curs_mv_back()...
= cut

=head2 curs_mv_down
Method curs_mv_down()...
= cut

=head2 curs_mv_fwd
Method curs_mv_fwd()...
= cut

=head2 curs_mv_left
Method curs_mv_left()...
= cut

=head2 curs_mv_right
Method curs_mv_right()...
= cut

=head2 curs_mv_up
Method curs_mv_up()...
= cut

=head2 dsp_coord
Method dsp_coord()...
= cut

=head2 init
Method init()...
= cut

=head2 register_evt_callbacks
Method register_evt_callbacks()...
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

