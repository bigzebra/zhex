#!/usr/bin/perl

package ZHex::Editor;

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

use Encode;   # <--- Provides function: decode().

# Functions: Initialization (start up) code.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   init()		Member variable declarations.

sub init {

	my $self = shift;

	# Declared here. Set via accessor methods.

	$self->{'horiz_rule_char'} = '';   # Word seperator: a vertical line used in display for readability.
	$self->{'oob_char'} = '';          # Out-of-bounds character: displayed in place of non-displayable characters.

	$self->{'sz_word'}   = '';     # Size: width (in characters) of a word.
	$self->{'sz_line'}   = '';     # Size: width (in characters) of a line.
	$self->{'sz_column'} = '';     # Size: height (in lines) of a column.

	$self->{'edt_ctxt'} = '';   # The editor context.
	$self->{'edt_pos'}  = '';   # The offset (in bytes) of the first character appearing at top/left of hex editor display.

	return (1);
}

# Functions: Accessors.
#
#   _____________		___________
#   Function Name		Description
#   _____________		___________
#   set_horiz_rule_char()	...
#   set_oob_char()		...
#   set_edt_ctxt()		Member variable accessor.
#   set_edt_pos()		Member variable accessor.
#   set_sz_word()		Member variable accessor.
#   set_sz_line()		Member variable accessor.
#   set_sz_column()		Member variable accessor.

sub set_horiz_rule_char {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_horiz_rule_char() failed, argument must be hash reference"; }

	if (! exists  $arg->{'char'} || 
	    ! defined $arg->{'char'} || 
	             ($arg->{'char'} eq '')) 
		{ die "Call to set_horiz_rule_char() failed, value of key 'char' may not be undef/empty"; }

	$self->{'horiz_rule_char'} = $arg->{'char'};

	return (1);
}

sub set_oob_char {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_oob_char() failed, argument must be hash reference"; }

	if (! exists  $arg->{'char'} || 
	    ! defined $arg->{'char'} || 
	             ($arg->{'char'} eq '')) 
		{ die "Call to set_oob_char() failed, value of key 'char' may not be undef/empty"; }

	$self->{'oob_char'} = $arg->{'char'};

	return (1);
}

sub set_edt_ctxt {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_edt_ctxt() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_ctxt'} || 
	    ! defined $arg->{'edt_ctxt'} || 
	             ($arg->{'edt_ctxt'} eq '')) 
		{ die "Call to set_edt_ctxt() failed, value of key 'edt_ctxt' may not be undef/empty"; }

	$self->{'edt_ctxt'} = $arg->{'edt_ctxt'};

	return (1);
}

sub set_edt_pos {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_edt_pos() failed, argument must be hash reference"; }

	if (! exists  $arg->{'edt_pos'} || 
	    ! defined $arg->{'edt_pos'} || 
	           ! ($arg->{'edt_pos'} =~ /^\d+?$/)) 
		{ die "Call to set_edt_pos() failed, value of key 'edt_pos' must be numeric"; }

	$self->{'edt_pos'} = $arg->{'edt_pos'};

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
		           $self->{'horiz_rule_char'}, 
		           join ('', @utf8_bytes), 
		           $self->{'horiz_rule_char'});
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
#   vstretch()			Stretch the editor display vertically.
#   vcompress()                 Compress the editor display vertically.
#   dsp_pos_adjust()		...
#   insert_mode()		INSERT_MODE	Switch to EDT_CTXT_INSERT context.
#   search_mode()		SEARCH_MODE	Switch to EDT_CTXT_SEARCH context.

sub scroll_up_1x_line {

	my $self = shift;

	if ($self->{'edt_pos'} < $self->{'sz_line'}) 
		{ return (undef); }

	$self->{'edt_pos'} -= $self->{'sz_line'};

	return (1);
}

sub scroll_down_1x_line {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to scroll_down_1x_line() failed, argument must be hash reference"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq '') || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to scroll_down_1x_line() failed, value associated w/ key 'file_len' must be one or more digits"; }

	if ($self->{'edt_pos'} > ($arg->{'file_len'} - ($self->{'sz_line'} * $self->{'sz_column'}))) 
		{ return (undef); }

	$self->{'edt_pos'} += $self->{'sz_line'};

	return (1); 
}

sub scroll_up_1x_page {

	my $self = shift;

	if (($self->{'edt_pos'} - ($self->{'sz_line'} * $self->{'sz_column'})) <= 0) 
		{ $self->{'edt_pos'} = 0; }   # Scroll to beginning of page (less than one full page).
	
	elsif (($self->{'edt_pos'} - ($self->{'sz_line'} * $self->{'sz_column'})) > 0) 
		{ $self->{'edt_pos'} -= ($self->{'sz_line'} * $self->{'sz_column'}); }   # Scroll one full page.

        return (1);
}

sub scroll_down_1x_page {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to scroll_down_1x_page() failed, argument must be hash reference"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq '') || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to scroll_down_1x_page() failed, value associated w/ key 'file_len' must be one or more digits"; }

	if (($self->{'edt_pos'} + ($self->{'sz_line'} * $self->{'sz_column'})) < 
	       ($arg->{'file_len'} - ($self->{'sz_line'} * $self->{'sz_column'}))) {

		$self->{'edt_pos'} += ($self->{'sz_line'} * $self->{'sz_column'});
	}
	elsif (($self->{'edt_pos'} + ($self->{'sz_line'} * $self->{'sz_column'})) > 
	          ($arg->{'file_len'} - ($self->{'sz_line'} * $self->{'sz_column'}))) {

		my $lines = ($arg->{'file_len'} / $self->{'sz_line'});
		if ($lines =~ s/\.\d+?$//) 
			{ $lines++; }

		$self->{'edt_pos'} = (($lines * $self->{'sz_line'}) - 
		                      ($self->{'sz_line'} * $self->{'sz_column'}));
	}
	else {

		return (undef); 
	}

	return (1);
}

sub vstretch {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to vstretch() failed, argument must be hash reference"; }

	if (! exists  $arg->{'max_columns'} || 
	    ! defined $arg->{'max_columns'} || 
	             ($arg->{'max_columns'} eq '') || 
	           ! ($arg->{'max_columns'} =~ /^\d+?$/)) 
		{ die "Call to vstretch() failed, value associated w/ key 'max_columns' must be one or more digits"; }

	if (! exists  $arg->{'file_len'} || 
	    ! defined $arg->{'file_len'} || 
	             ($arg->{'file_len'} eq '') || 
	           ! ($arg->{'file_len'} =~ /^\d+?$/)) 
		{ die "Call to vstretch() failed, value associated w/ key 'file_len' must be one or more digits"; }

	if ($self->{'sz_column'} < $arg->{'max_columns'}) {

		$self->set_sz_column 
		  ({ 'sz_column' => ($self->{'sz_column'} + 1) });

		if ($self->{'edt_pos'} > 
		      ($arg->{'file_len'} - 
			 (($self->{'sz_column'} * $self->{'sz_line'}) - 
		            $self->{'sz_line'}))) {

			$self->set_edt_pos 
			  ({ 'edt_pos' => ($self->{'edt_pos'} - 
			                   $self->{'sz_line'}) });
		}
	}

	return (1);
}

sub vcompress {

	my $self = shift;

	if ($self->{'sz_column'} > 1) {

		$self->set_sz_column 
		  ({ 'sz_column' => ($self->{'sz_column'} - 1) });
	}

	return (1);
}

sub dsp_pos_adjust {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to dsp_pos_adjust() failed, argument must be hash reference"; }

	if (! exists  $arg->{'curs_pos'} || 
	    ! defined $arg->{'curs_pos'} || 
	             ($arg->{'curs_pos'} eq '') || 
	           ! ($arg->{'curs_pos'} =~ /^\d+?$/)) 
		{ die "Call to dsp_pos_adjust() failed, value associated w/ key 'curs_pos' must be one or more digits"; }

	# If curs_pos is OOB: adjust display position [curs_mv_up].

	while ($self->{'edt_pos'} > $arg->{'curs_pos'}) 
		{ $self->{'edt_pos'} -= $self->{'sz_line'}; }

	# If curs_pos is OOB: adjust display position [curs_mv_up].

	while ($self->{'edt_pos'} <= ($arg->{'curs_pos'} - 
	                               ($self->{'sz_line'} * $self->{'sz_column'})))
		{ $self->{'edt_pos'} += $self->{'sz_line'}; }

	return (1);
}

sub insert_mode {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};     # Used.
	my $objCursor    = $self->{'obj'}->{'cursor'};      # Used.
	my $objDisplay   = $self->{'obj'}->{'display'};     # Used.
	my $objEditor    = $self->{'obj'}->{'editor'};      # Used.
	my $objEventLoop = $self->{'obj'}->{'eventloop'};   # Used.

	# Switch context to EDT_CTXT_INSERT.

	$self->{'edt_ctxt'} = EDT_CTXT_INSERT;

	# Change cursor context to 3 (insert mode).

	if (! ($objCursor->set_curs_ctxt ({'curs_ctxt' => 3}))) 
		{ die "Call to set_curs_ctxt w/ argument '3' returned w/ failure"; }

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
	       'edt_pos'  => $self->{'edt_pos'}, 
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

	# Switch editor context to EDT_CTXT_SEARCH.

	$self->{'edt_ctxt'} = EDT_CTXT_SEARCH;

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

=head2 dsp_pos_adjust
Method dsp_pos_adjust()...
= cut

=head2 vcompress
Method vcompress()...
= cut

=head2 vstretch
Method vstretch()...
= cut

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

=head2 insert_mode
Method insert_mode()...
= cut

=head2 register_evt_callbacks
Method register_evt_callbacks()...
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

=head2 search_mode
Method search_mode()...
= cut

=head2 set_ctxt
Method set_ctxt()...
= cut

=head2 set_edt_pos
Method set_edt_pos()...
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

