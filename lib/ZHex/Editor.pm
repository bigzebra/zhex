#!/usr/bin/perl

package ZHex::Editor;

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

use Encode;   # <--- Provides function: decode().

# Functions: Initialization (start up) code.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Member variable declarations.

sub init {

	my $self = shift;

	# HAVE ACCESSOR(S):

	$self->{'dsp_pos'}   =  '';   # The first character (byte number) appearing at top/left of hex editor display.
	$self->{'sz_word'}   =  '';   # Size: width (in characters) of a word.
	$self->{'sz_line'}   =  '';   # Size: width (in characters) of a line.
	$self->{'sz_column'} =  '';   # Size: height (in lines) of a column.

	# NEED ACCESSOR(S):

	$self->{'horiz_rule'} = '|';   # Word seperator: a vertical line used in display for readability.
	$self->{'oob_char'}   = '-';   # Out-of-bounds character: displayed in place of non-displayable characters.

	return (1);
}

# Functions: Accessors.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   set_dsp_pos()	Member variable accessor.
#   set_sz_line()	Member variable accessor.
#   set_sz_column()	Member variable accessor.
#   set_sz_word()	Member variable accessor.

sub set_dsp_pos {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_sz_dsp_pos() failed, argument must be hash reference"; }

	if (! exists  $arg->{'dsp_pos'} || 
	    ! defined $arg->{'dsp_pos'} || 
	           ! ($arg->{'dsp_pos'} =~ /^\d+?$/)) 
		{ die "Call to set_sz_dsp_pos() failed, value of key 'dsp_pos' must be numeric"; }

	$self->{'dsp_pos'} = $arg->{'dsp_pos'};

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

# Functions: Generate display elements.
#
#   ____		___________
#   NAME		DESCRIPTION
#   ____		___________
#   gen_hdr()		Format column titles for display console.
#   gen_ofs_hex()	
#   gen_ofs_dec()	
#   gen_hex()		
#   gen_char()		
#   gen_lnum()		
#   gen_sep()		Format column horizontal rules (seperators) for display console.

sub gen_hdr {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_sep() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_elements'} || 
	    ! defined $arg->{'d_elements'} || 
	             ($arg->{'d_elements'} eq '') || 
	      ! (ref ($arg->{'d_elements'}) eq 'HASH')) 
		{ die "Call to gen_sep() failed, value associated w/ key 'd_elements' must be hash reference"; }

	# Generate column descriptors: 
	#   - Headlines over top of columns which describe contents of each column.
	#   - One for each column.
	#   - Joined together, forming one element which spans width of all columns.
	#   - Located at top of console display.
	#   - 3 characters height x <column_width> width.

	my @hdr_ofs_hex = 
	  ('______________________', 
	   '[Offset-(Hexidecimal)]', 
	   '____First_->_Last_____');
	#  '1234567890123456789012'

	# Subheading: OFFSETS (DEC) [18 chars length].

	my @hdr_ofs_dec = 
	  ('__________________', 
	   '[Offset-(Decimal)]', 
	   '__First_->_Last___');
	#  '123456789012345678'

	# Subheading: WORD 1 [10 chars length].

	my @hdr_w1 = 
	  ('__________', 
	   '[Word--#1]', 
	   '_(4_Byte)_');
	#  '1234567890'

	# Subheading: WORD 2 [10 chars length].

	my @hdr_w2 = 
	  ('__________', 
	   '[Word--#2]', 
	   '_(4_Byte)_');
	#  '1234567890'

	# Subheading: WORD 3 [10 chars length].

	my @hdr_w3 = 
	  ('__________', 
	   '[Word--#3]', 
	   '_(4_Byte)_');
	#  '1234567890'

	# Subheading: WORD 4 [10 chars length].

	my @hdr_w4 = 
	  ('__________', 
	   '[Word--#4]', 
	   '_(4_Byte)_');
	#  '1234567890'

	# Subheading: CHARACTER DISPLAY [21 chars length].

	# my @hdr_chr_dsp = 
	#   ('_____________________', 
	#    '[_Character_Display_]', 
	#    '|_w1_|_w2_|_w3_|_w4_|');
	#    '123456789012345678901'

	my @hdr_chr_dsp = 
	  ('__________________', 
	   '[__Char_Display__]', 
	   '|(w1)(w2)(w3)(w4)|');
	#  '123456789012345678'

	# Subheading: LINE NUMBER [5 chars length].

	my @hdr_line_num = 
	  ('______', 
	   '[Line]', 
	   '______');
	#  '123456'

	# Join set of 7 column descriptors together: 
	#   result is "banner" 3 rows tall and 105 characters wide (see below).

	my @hdr = 
	  # Line 1.
	  (((($arg->{'d_elements'}->{'ofs_hex'}->{'enabled'}     == 1) ? $hdr_ofs_hex[0]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'ofs_dec'}->{'enabled'}     == 1) ? $hdr_ofs_dec[0]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) ? join (' ', $hdr_w1[0], $hdr_w2[0], $hdr_w3[0], $hdr_w4[0]) . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'char_disp'}->{'enabled'}   == 1) ? $hdr_chr_dsp[0]                                            . ' ' x 1 : '') . 
	    (($arg->{'d_elements'}->{'line_num'}->{'enabled'}    == 1) ? $hdr_line_num[0] : '')), 

	   # Line 2.
	   ((($arg->{'d_elements'}->{'ofs_hex'}->{'enabled'}     == 1) ? $hdr_ofs_hex[1]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'ofs_dec'}->{'enabled'}     == 1) ? $hdr_ofs_dec[1]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) ? join (' ', $hdr_w1[1], $hdr_w2[1], $hdr_w3[1], $hdr_w4[1]) . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'char_disp'}->{'enabled'}   == 1) ? $hdr_chr_dsp[1]                                            . ' ' x 1 : '') . 
	    (($arg->{'d_elements'}->{'line_num'}->{'enabled'}    == 1) ? $hdr_line_num[1] : '')), 

	   # Line 3.
	   ((($arg->{'d_elements'}->{'ofs_hex'}->{'enabled'}     == 1) ? $hdr_ofs_hex[2]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'ofs_dec'}->{'enabled'}     == 1) ? $hdr_ofs_dec[2]                                            . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) ? join (' ', $hdr_w1[2], $hdr_w2[2], $hdr_w3[2], $hdr_w4[2]) . ' ' x 2 : '') . 
	    (($arg->{'d_elements'}->{'char_disp'}->{'enabled'}   == 1) ? $hdr_chr_dsp[2]                                            . ' ' x 1 : '') . 
	    (($arg->{'d_elements'}->{'line_num'}->{'enabled'}    == 1) ? $hdr_line_num[2] : '')));

	return (\@hdr);
}

sub gen_ofs_hex {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_ofs_hex() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_hex() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_hex() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_hex() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_hex() failed, value associated w/ key 'f_size' must be one or more digits"; }

	my @lines;
	for (my $ofs =  $arg->{'pos'}; 
	        $ofs < ($arg->{'pos'} + ($arg->{'sz_line'} * $arg->{'sz_column'})); 
	        $ofs += $arg->{'sz_line'}) {

		# Offset (in hexidecimal) of last character in the line.

		my $last_byte;
		if ($ofs <= ($arg->{'f_size'} - $arg->{'sz_line'})) 
		     { $last_byte = (($ofs + $arg->{'sz_line'}) - 1); }
		else { $last_byte = ($arg->{'f_size'} - 1); }

		# Push formatted text string onto list (to be returned to caller).

		push @lines, sprintf ("0x%-08.8x%2.2s0x%-08.8x  ", $ofs, "->", $last_byte);
	}

	return (\@lines);
}

sub gen_ofs_dec {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_ofs_dec() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_dec() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_dec() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_dec() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_ofs_dec() failed, value associated w/ key 'f_size' must be one or more digits"; }

	my @lines;
	for (my $ofs =  $arg->{'pos'}; 
	        $ofs < ($arg->{'pos'} + ($arg->{'sz_line'} * $arg->{'sz_column'})); 
	        $ofs += $arg->{'sz_line'}) {

		# Offset (in decimal) of last character in the line.

		my $last_byte;
		if ($ofs <= ($arg->{'f_size'} - $arg->{'sz_line'})) {

			$last_byte = (($ofs + $arg->{'sz_line'}) - 1);
		}
		else {

			$last_byte = ($arg->{'f_size'} - 1);
		}

		# Push formatted text string onto list (to be returned to caller).

		push @lines, 
		  sprintf ("%-08.8d%2.2s%-08.8d  ", 
		           $ofs, 
		           "->", 
		           $last_byte);
	}

	return (\@lines);
}

sub gen_hex {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_hex() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex() failed, value associated w/ key 'f_size' must be one or more digits"; }

	my $objFile = $self->{'obj'}->{'file'};

	my @lines;
	for (my $ofs =  $arg->{'pos'}; 
	        $ofs < ($arg->{'pos'} + ($arg->{'sz_line'} * $arg->{'sz_column'})); 
	        $ofs += $arg->{'sz_line'}) {

		# Offset of last character in line.

		my $last_byte;
		if ($ofs <= ($arg->{'f_size'} - $arg->{'sz_line'})) {

			$last_byte = ($ofs + ($arg->{'sz_line'} - 1));
		}
		else {

			$last_byte = ($arg->{'f_size'} - 1);
		}

		my $raw_bytes = 
		  $objFile->file_bytes 
		    ({ 'ofs' => $ofs, 
		       'len' => (($last_byte - $ofs) + 1) });

		my @hex_bytes;
		foreach my $raw_byte (@{ $raw_bytes }) {

			push @hex_bytes, (unpack ("H2", $raw_byte));
		}

		# Push formatted text string onto list (to be returned to caller).

		my $fmt_str = ("%-" . ($arg->{'sz_line'} * 2) . "." . ($arg->{'sz_line'} * 2) . "s");
		push @lines, 
		  sprintf ($fmt_str, 
		           join ('', @hex_bytes));
	}

	return (\@lines);
}

sub gen_hex_cols {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_hex_cols() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'f_size' must be one or more digits"; }

	if (! exists  $arg->{'col_ct'} || 
	    ! defined $arg->{'col_ct'} || 
	             ($arg->{'col_ct'} eq '') || 
	           ! ($arg->{'col_ct'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'f_size' must be one or more digits"; }

	if ($arg->{'col_ct'} < 1) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'col_ct' may not be lower than 1"; }

	my $remainder = $arg->{'sz_line'} % $arg->{'col_ct'};

	if (defined $remainder && 
	         ! ($remainder eq '') && 
	           ($remainder =~ /^\d+?$/) && 
	         ! ($remainder == 0)) 
		{ die "Call to gen_hex_cols() failed, argument 'sz_line' divided by argument 'col_ct' may not leave a remainder"; }

	if (! exists  $arg->{'hpad'} || 
	    ! defined $arg->{'hpad'} || 
	             ($arg->{'hpad'} eq '') || 
	           ! ($arg->{'hpad'} =~ /^\d+?$/)) 
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'hpad' must be one or more digits"; }

	if (! exists  $arg->{'prefix'} || 
	    ! defined $arg->{'prefix'})
		{ die "Call to gen_hex_cols() failed, value associated w/ key 'prefix' must be defined"; }

	my $gen_hex_lines = 
	  $self->gen_hex 
	    ({ 'pos'       => $arg->{'pos'}, 
	       'sz_line'   => $arg->{'sz_line'},
	       'sz_column' => $arg->{'sz_column'}, 
	       'f_size'    => $arg->{'f_size'} });

	my $col_sz  = $arg->{'sz_line'} / $arg->{'col_ct'};
	my $fmt_str = ("%-" . ($col_sz * 2) . "." . ($col_sz * 2) . "s");

	my @lines;
	for (my $lnum = 0; 
	        $lnum < scalar (@{ $gen_hex_lines }); 
	        $lnum++) {

		my @cols;
		for (my $i = 0; 
		        $i < $arg->{'col_ct'}; 
		        $i++) {

			push @cols, 
			  sprintf ($fmt_str, 
			    substr $gen_hex_lines->[$lnum], 
			           (($i * $col_sz) * 2), 
			           ($col_sz * 2));
		}

		push @lines, 
		  $arg->{'prefix'} . 
		  join (((' ' x $arg->{'hpad'}) . $arg->{'prefix'}), 
		        @cols);
	}

	return (\@lines);
}

sub gen_char {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_char() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_char() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_char() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_char() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_char() failed, value associated w/ key 'f_size' must be one or more digits"; }

	my $objFile = $self->{'obj'}->{'file'};

	my @lines;
	for (my $ofs =  $arg->{'pos'}; 
	        $ofs < ($arg->{'pos'} + ($arg->{'sz_line'} * $arg->{'sz_column'})); 
	        $ofs += $arg->{'sz_line'}) {

		# Offset of last character in line.

		my $last_byte;
		if ($ofs <= ($arg->{'f_size'} - $arg->{'sz_line'})) {

			$last_byte = ($ofs + ($arg->{'sz_line'} - 1));
		}
		else {

			$last_byte = ($arg->{'f_size'} - 1);
		}

		my $raw_bytes = 
		  $objFile->file_bytes 
		    ({ 'ofs' => $ofs, 
		       'len' => (($last_byte - $ofs) + 1) });

		my @utf8_bytes;
		foreach my $raw_byte (@{ $raw_bytes }) {

			if ((ord ($raw_byte) < 32) || 
			    (ord ($raw_byte) > 126)) 
			     { push @utf8_bytes, $self->{'oob_char'}; }
			else { push @utf8_bytes, decode ('UTF-8', $raw_byte); }
		}

		# Push formatted text string onto list (to be returned to caller).

		my $fmt_str = ("%1.1s%-" . $arg->{'sz_line'} . "." . $arg->{'sz_line'} . "s%1.1s");

		push @lines, 
		  sprintf ($fmt_str, 
		           $self->{'horiz_rule'}, 
		           join ('', @utf8_bytes), 
		           $self->{'horiz_rule'});
	}

	return (\@lines);
}

sub gen_lnum {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_lnum() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to gen_lnum() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'sz_line'} || 
	    ! defined $arg->{'sz_line'} || 
	             ($arg->{'sz_line'} eq '') || 
	           ! ($arg->{'sz_line'} =~ /^\d+?$/)) 
		{ die "Call to gen_lnum() failed, value associated w/ key 'sz_line' must be one or more digits"; }

	if (! exists  $arg->{'sz_column'} || 
	    ! defined $arg->{'sz_column'} || 
	             ($arg->{'sz_column'} eq '') || 
	           ! ($arg->{'sz_column'} =~ /^\d+?$/)) 
		{ die "Call to gen_lnum() failed, value associated w/ key 'sz_column' must be one or more digits"; }

	if (! exists  $arg->{'f_size'} || 
	    ! defined $arg->{'f_size'} || 
	             ($arg->{'f_size'} eq '') || 
	           ! ($arg->{'f_size'} =~ /^\d+?$/)) 
		{ die "Call to gen_lnum() failed, value associated w/ key 'f_size' must be one or more digits"; }

	my @lines;
	for (my $ofs =  $arg->{'pos'}; 
	        $ofs < ($arg->{'pos'} + ($arg->{'sz_line'} * $arg->{'sz_column'})); 
	        $ofs += $arg->{'sz_line'}) {

		# Line number of the line (based on sz_line).

		my $line_num = ($ofs / $arg->{'sz_line'});
		$line_num =~ s/\.\d+?$//;

		# Add line to list of lines.

		push @lines, sprintf ("%6.6s", ('.' x (5 - length ($line_num)) . ' ' . $line_num));
	}

	return (\@lines);
}

sub gen_sep {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to gen_sep() failed, argument must be hash reference"; }

	if (! exists  $arg->{'d_elements'} || 
	    ! defined $arg->{'d_elements'} || 
	             ($arg->{'d_elements'} eq '') || 
	      ! (ref ($arg->{'d_elements'}) eq 'HASH')) 
		{ die "Call to gen_sep() failed, value associated w/ key 'd_elements' must be hash reference"; }

	# Generate horizontal rule (seperator) to break up long columns of data.

	my @sep_elements;

	# Offset (in hexidecimal) column.

	if ($arg->{'d_elements'}->{'ofs_hex'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x $arg->{'d_elements'}->{'ofs_hex'}->{'e_width'} . 
	                         ' ' x $arg->{'d_elements'}->{'ofs_hex'}->{'hpad'}); }

	# Offset (in decimal) column.

	if ($arg->{'d_elements'}->{'ofs_dec'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x $arg->{'d_elements'}->{'ofs_dec'}->{'e_width'} . 
	                         ' ' x $arg->{'d_elements'}->{'ofs_dec'}->{'hpad'}); }

	# Hex display column #1.

	if ($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x (($arg->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) . 
	                         ' ' x 1); }

	# Hex display column #2.

	if ($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x (($arg->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) . 
	                         ' ' x 1); }

	# Hex display column #3.

	if ($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x (($arg->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) . 
	                         ' ' x 1); }

	# Hex display column #4.

	if ($arg->{'d_elements'}->{'editor_disp'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x (($arg->{'d_elements'}->{'editor_disp'}->{'e_width'} - 3) / 4) . 
	                         ' ' x   $arg->{'d_elements'}->{'editor_disp'}->{'hpad'}); }

	# Character display columns.

	if ($arg->{'d_elements'}->{'char_disp'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x $arg->{'d_elements'}->{'char_disp'}->{'e_width'} . 
	                         ' ' x $arg->{'d_elements'}->{'char_disp'}->{'hpad'}); }

	# Line number column.

	if ($arg->{'d_elements'}->{'line_num'}->{'enabled'} == 1) 
	  { push @sep_elements, ('_' x $arg->{'d_elements'}->{'line_num'}->{'e_width'}); }

	my $sep = join '', @sep_elements;

	my $sep_rtn = [];
	push @{ $sep_rtn }, $sep;

	return ($sep_rtn);
}

# Scrolling Functions.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   scroll_up_1x_line()		Scroll up   one line.
#   scroll_down_1x_line()	Scroll down one line.
#   scroll_up_1x_page()		Scroll up   one page.
#   scroll_down_1x_page()	Scroll down one page.

sub scroll_up_1x_line {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};

	if ($self->{'dsp_pos'} < $self->{'sz_line'}) 
		{ return (undef); }

	$self->{'dsp_pos'} -= $self->{'sz_line'};

	# Update cursor (if cursor is no longer located within editor display).

	while ($objCursor->{'curs_pos'} >= 
	         ($self->{'dsp_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}))) 
		{ $objCursor->{'curs_pos'} -= $self->{'sz_line'}; }

	return (1);
}

sub scroll_down_1x_line {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objFile   = $self->{'obj'}->{'file'};

	if ($self->{'dsp_pos'} > ($objFile->file_len() - ($self->{'sz_line'} * $self->{'sz_column'}))) 
		{ return (undef); }

	$self->{'dsp_pos'} += $self->{'sz_line'};

	# Update cursor (if cursor is no longer located within editor display).

	while ($objCursor->{'curs_pos'} < $self->{'dsp_pos'}) 
		{ $objCursor->{'curs_pos'} += $self->{'sz_line'}; }

	return (1); 
}

sub scroll_up_1x_page {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};

	if (($self->{'dsp_pos'} - ($self->{'sz_line'} * $self->{'sz_column'})) <= 0) 
		{ $self->{'dsp_pos'} = 0; }   # Scroll to beginning of page (less than one full page).
	
	elsif (($self->{'dsp_pos'} - ($self->{'sz_line'} * $self->{'sz_column'})) > 0) 
		{ $self->{'dsp_pos'} -= ($self->{'sz_line'} * $self->{'sz_column'}); }   # Scroll one full page.

	# Update cursor (if cursor is no longer located within editor display).

	while (($objCursor->{'curs_ctxt'} == 0) && 
	       ($objCursor->{'curs_pos'} > ($self->{'dsp_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}) - $self->{'sz_line'}))) 
		{ $objCursor->{'curs_pos'} -= $self->{'sz_line'}; }

	while ((($objCursor->{'curs_ctxt'} == 1)  || 
	        ($objCursor->{'curs_ctxt'} == 2)) && 
	        ($objCursor->{'curs_pos'} > ($self->{'dsp_pos'} + ($self->{'sz_line'} * $self->{'sz_column'}) - 1))) 
		{ $objCursor->{'curs_pos'} -= $self->{'sz_line'}; }

        return (1);
}

sub scroll_down_1x_page {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objFile   = $self->{'obj'}->{'file'};

	if (($self->{'dsp_pos'} + ($self->{'sz_line'} * $self->{'sz_column'})) < 
	       ($objFile->file_len() - ($self->{'sz_line'} * $self->{'sz_column'}))) {

		$self->{'dsp_pos'} += ($self->{'sz_line'} * $self->{'sz_column'});
	}
	elsif (($self->{'dsp_pos'} + ($self->{'sz_line'} * $self->{'sz_column'})) > 
	          ($objFile->file_len() - ($self->{'sz_line'} * $self->{'sz_column'}))) {

		my $lines = ($objFile->file_len() / $self->{'sz_line'});
		if ($lines =~ s/\.\d+?$//) 
			{ $lines++; }

		$self->{'dsp_pos'} = (($lines * $self->{'sz_line'}) - 
		                      ($self->{'sz_line'} * $self->{'sz_column'}));
	}
	else {

		return (undef); 
	}

	# Update cursor (if cursor is no longer located within editor display).

	while ($objCursor->{'curs_pos'} < $self->{'dsp_pos'}) 
		{ $objCursor->{'curs_pos'} += $self->{'sz_line'}; }

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::Editor (ZHex/Editor.pm) - Editor Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::Editor module defines functions specific to the hex editor 
display (generating the display, scrolling, and highlighting specific areas 
within the display (with color).

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objEditor = $self->{'obj'}->{'editor'};
    $objEditor->scroll_up_1x_line();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 gen_char
Method gen_char()...
= cut

=head2 gen_hdr
Method gen_hdr()...
= cut

=head2 gen_hex
Method gen_hex()...
= cut

=head2 gen_hex_cols
Method gen_hex_cols()...
= cut

=head2 gen_lnum
Method gen_lnum()...
= cut

=head2 gen_ofs_dec
Method gen_ofs_dec()...
= cut

=head2 gen_ofs_hex
Method gen_ofs_hex()...
= cut

=head2 gen_sep
Method gen_sep()...
= cut

=head2 init
Method init()...
= cut

=head2 scroll_down_1x_line
Method scroll_down_1x_line()...
= cut

=head2 scroll_down_1x_page
Method scroll_down_1x_page()...
= cut

=head2 scroll_up_1x_line
Method scroll_up_1x_line()...
= cut

=head2 scroll_up_1x_page
Method scroll_up_1x_page()...
= cut

=head2 set_dsp_pos
Method set_dsp_pos()...
= cut

=head2 set_sz_column
Method set_sz_column()...
= cut

=head2 set_sz_line
Method set_sz_line()...
= cut

=head2 set_sz_word
Method set_sz_word()...
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

