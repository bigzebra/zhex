#!/usr/bin/perl -w

package ZHex::CharMap;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     init_obj 
     init_child_obj 
     check_args 
     ZHEX_VERSION);

BEGIN { require Exporter;
	our $VERSION   = ZHEX_VERSION;
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

	$self->{'chr_map'} = '';

	return (1);
}

# Functions: Character Mapping.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   chr_map_set()	...
#   chr_map_hex_val()	...
#   chr_map_ord_val()	...   <--- Memoized...
#   chr_map()		...

sub chr_map_set {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'chr_map_set',
	     'test' => 
		[{'chr_map' => 'hashref'}] });

	$self->{'chr_map'} = $arg->{'chr_map'};

	return (1);
}

sub chr_map_ord_val {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg, 
	     'func' => 'chr_map_ord_val', 
	     'test' => 
		[{'lname' => 'string'}] });

	if (exists  $self->{'chr_map'} && 
	    defined $self->{'chr_map'} && 
	    exists  $self->{'chr_map'}->{ $arg->{'lname'} } && 
	    defined $self->{'chr_map'}->{ $arg->{'lname'} } && 
	    exists  $self->{'chr_map'}->{ $arg->{'lname'} }->{'ord'} && 
	    defined $self->{'chr_map'}->{ $arg->{'lname'} }->{'ord'}) {

		return ($self->{'chr_map'}->{ $arg->{'lname'} }->{'ord'});
	}
	else {

		return (undef);
	}
}

sub chr_map {

	my $self = shift;

	my $chr_map = 
	  { 'NULL' => 
	    { 'ord' => '0', 
	      'hex'  => '00' }, 
	  'START OF HEADING' => 
	    { 'ord' => '1', 
	      'hex'  => '01'}, 
	  'START OF TEXT' => 
	    { 'ord'  => '2', 
	      'hex'  => '02'}, 
	  'END OF TEXT' => 
	    { 'ord'  => '3', 
	      'hex'  => '03'}, 
	  'END OF TRANSMISSION' => 
	    { 'ord'  => '4', 
	      'hex'  => '04'}, 
	  'ENQUIRY' => 
	    { 'ord'  => '5', 
	      'hex'  => '05'}, 
	  'ACKNOWLEDGE' => 
	    { 'ord'  => '6', 
	      'hex'  => '06'}, 
	  'BELL' => 
	    { 'ord'  => '7', 
	      'hex'  => '07'}, 
	  'BACKSPACE' => 
	    { 'ord'  => '8', 
	      'hex'  => '08'}, 
	  'CHARACTER TABULATION' => 
	    { 'ord'  => '9', 
	      'hex'  => '09'}, 
	  'LINE FEED (LF)' => 
	    { 'ord'  => '10', 
	      'hex'  => '0a'}, 
	  'LINE TABULATION' => 
	    { 'ord'  => '11', 
	      'hex'  => '0b'}, 
	  'FORM FEED (FF)' => 
	    { 'ord'  => '12', 
	      'hex'  => '0c'}, 
	  'CARRIAGE RETURN (CR)' => 
	    { 'ord'  => '13', 
	      'hex'  => '0d'}, 
	  'SHIFT OUT' => 
	    { 'ord'  => '14', 
	      'hex'  => '0e'}, 
	  'SHIFT IN' => 
	    { 'ord'  => '15', 
	      'hex'  => '0f'}, 
	  'DATA LINK ESCAPE' => 
	    { 'ord'  => '16', 
	      'hex'  => '10'}, 
	  'DEVICE CONTROL ONE' => 
	    { 'ord'  => '17', 
	      'hex'  => '11'}, 
	  'DEVICE CONTROL TWO' => 
	    { 'ord'  => '18', 
	      'hex'  => '12'}, 
	  'DEVICE CONTROL THREE' => 
	    { 'ord'  => '19', 
	      'hex'  => '13'}, 
	  'DEVICE CONTROL FOUR' => 
	    { 'ord'  => '20', 
	      'hex'  => '14'}, 
	  'NEGATIVE ACKNOWLEDGE' => 
	    { 'ord'  => '21', 
	      'hex'  => '15'}, 
	  'SYNCHRONOUS IDLE' => 
	    { 'ord'  => '22', 
	      'hex'  => '16'}, 
	  'END OF TRANSMISSION BLOCK' => 
	    { 'ord'  => '23', 
	      'hex'  => '17'}, 
	  'CANCEL' => 
	    { 'ord'  => '24', 
	      'hex'  => '18'}, 
	  'END OF MEDIUM' => 
	    { 'ord'  => '25', 
	      'hex'  => '19'}, 
	  'SUBSTITUTE' => 
	    { 'ord'  => '26', 
	      'hex'  => '1a'}, 
	  'ESCAPE' => 
	    { 'ord'  => '27', 
	      'hex'  => '1b'}, 
	  'INFORMATION SEPARATOR FOUR' => 
	    { 'ord'  => '28', 
	      'hex'  => '1c'}, 
	  'INFORMATION SEPARATOR THREE' => 
	    { 'ord'  => '29', 
	      'hex'  => '1d'}, 
	  'INFORMATION SEPARATOR TWO' => 
	    { 'ord'  => '30', 
	      'hex'  => '1e'}, 
	  'INFORMATION SEPARATOR ONE' => 
	    { 'ord'  => '31', 
	      'hex'  => '1f'}, 
	  'SPACE' => 
	    { 'ord'  => '32', 
	      'hex'  => '20'}, 
	  'EXCLAMATION MARK' => 
	    { 'ord'  => '33', 
	      'hex'  => '21'}, 
	  'QUOTATION MARK' => 
	    { 'ord'  => '34', 
	      'hex'  => '22'}, 
	  'NUMBER SIGN' => 
	    { 'ord'  => '35', 
	      'hex'  => '23'}, 
	  'DOLLAR SIGN' => 
	    { 'ord'  => '36', 
	      'hex'  => '24'}, 
	  'PERCENT SIGN' => 
	    { 'ord'  => '37', 
	      'hex'  => '25'}, 
	  'AMPERSAND' =>  
	    { 'ord'  => '38', 
	      'hex'  => '26'}, 
	  'APOSTROPHE' =>  
	    { 'ord'  => '39', 
	      'hex'  => '27'}, 
	  'LEFT PARENTHESIS' => 
	    { 'ord'  => '40', 
	      'hex'  => '28'}, 
	  'RIGHT PARENTHESIS' => 
	    { 'ord'  => '41', 
	      'hex'  => '29'}, 
	  'ASTERISK' => 
	    { 'ord'  => '42', 
	      'hex'  => '2a'}, 
	  'PLUS SIGN' => 
	    { 'ord'  => '43', 
	      'hex'  => '2b'}, 
	  'COMMA' => 
	    { 'ord'  => '44', 
	      'hex'  => '2c'}, 
	  'HYPHEN-MINUS' => 
	    { 'ord'  => '45', 
	      'hex'  => '2d'}, 
	  'FULL STOP' => 
	    { 'ord'  => '46', 
	      'hex'  => '2e'}, 
	  'SOLIDUS' => 
	    { 'ord'  => '47', 
	      'hex'  => '2f'}, 
	  'DIGIT ZERO' => 
	    { 'ord'  => '48', 
	      'hex'  => '30'}, 
	  'DIGIT ONE' => 
	    { 'ord'  => '49', 
	      'hex'  => '31'}, 
	  'DIGIT TWO' => 
	    { 'ord'  => '50', 
	      'hex'  => '32'}, 
	  'DIGIT THREE' => 
	    { 'ord'  => '51', 
	      'hex'  => '33'}, 
	  'DIGIT FOUR' => 
	    { 'ord'  => '52', 
	      'hex'  => '34'}, 
	  'DIGIT FIVE' => 
	    { 'ord'  => '53', 
	      'hex'  => '35'}, 
	  'DIGIT SIX' => 
	    { 'ord'  => '54', 
	      'hex'  => '36'}, 
	  'DIGIT SEVEN' => 
	    { 'ord'  => '55', 
	      'hex'  => '37'}, 
	  'DIGIT EIGHT' => 
	    { 'ord'  => '56', 
	      'hex'  => '38'}, 
	  'DIGIT NINE' => 
	    { 'ord'  => '57', 
	      'hex'  => '39'}, 
	  'COLON' => 
	    { 'ord'  => '58', 
	      'hex'  => '3a'}, 
	  'SEMICOLON' => 
	    { 'ord'  => '59', 
	      'hex'  => '3b'}, 
	  'LESS-THAN SIGN' => 
	    { 'ord'  => '60', 
	      'hex'  => '3c'}, 
	  'EQUALS SIGN' => 
	    { 'ord'  => '61', 
	      'hex'  => '3d'}, 
	  'GREATER-THAN SIGN' => 
	    { 'ord'  => '62', 
	      'hex'  => '3e'}, 
	  'QUESTION MARK' => 
	    { 'ord'  => '63', 
	      'hex'  => '3f'}, 
	  'COMMERCIAL AT' => 
	    { 'ord'  => '64', 
	      'hex'  => '40'}, 
	  'LATIN CAPITAL LETTER A' => 
	    { 'ord'  => '65', 
	      'hex'  => '41'}, 
	  'LATIN CAPITAL LETTER B' => 
	    { 'ord'  => '66', 
	      'hex'  => '42'}, 
	  'LATIN CAPITAL LETTER C' => 
	    { 'ord'  => '67', 
	      'hex'  => '43'}, 
	  'LATIN CAPITAL LETTER D' => 
	    { 'ord'  => '68', 
	      'hex'  => '44'}, 
	  'LATIN CAPITAL LETTER E' => 
	    { 'ord'  => '69', 
	      'hex'  => '45'}, 
	  'LATIN CAPITAL LETTER F' => 
	    { 'ord'  => '70', 
	      'hex'  => '46'}, 
	  'LATIN CAPITAL LETTER G' => 
	    { 'ord'  => '71', 
	      'hex'  => '47'}, 
	  'LATIN CAPITAL LETTER H' => 
	    { 'ord'  => '72', 
	      'hex'  => '48'}, 
	  'LATIN CAPITAL LETTER I' => 
	    { 'ord'  => '73', 
	      'hex'  => '49'}, 
	  'LATIN CAPITAL LETTER J' => 
	    { 'ord'  => '74', 
	      'hex'  => '4a'}, 
	  'LATIN CAPITAL LETTER K' => 
	    { 'ord'  => '75', 
	      'hex'  => '4b'}, 
	  'LATIN CAPITAL LETTER L' => 
	    { 'ord'  => '76', 
	      'hex'  => '4c'}, 
	  'LATIN CAPITAL LETTER M' => 
	    { 'ord'  => '77', 
	      'hex'  => '4d'},
	  'LATIN CAPITAL LETTER N' => 
	    { 'ord'  => '78', 
	      'hex'  => '4e'}, 
	  'LATIN CAPITAL LETTER O' => 
	    { 'ord'  => '79', 
	      'hex'  => '4f'}, 
	  'LATIN CAPITAL LETTER P' => 
	    { 'ord'  => '80', 
	      'hex'  => '50'}, 
	  'LATIN CAPITAL LETTER Q' => 
	    { 'ord'  => '81', 
	      'hex'  => '51'}, 
	  'LATIN CAPITAL LETTER R' => 
	    { 'ord'  => '82', 
	      'hex'  => '52'}, 
	  'LATIN CAPITAL LETTER S' => 
	    { 'ord'  => '83', 
	      'hex'  => '53'}, 
	  'LATIN CAPITAL LETTER T' => 
	    { 'ord'  => '84', 
	      'hex'  => '54'}, 
	  'LATIN CAPITAL LETTER U' => 
	    { 'ord'  => '85', 
	      'hex'  => '55'}, 
	  'LATIN CAPITAL LETTER V' => 
	    { 'ord'  => '86', 
	      'hex'  => '56'}, 
	  'LATIN CAPITAL LETTER W' => 
	    { 'ord'  => '87', 
	      'hex'  => '57'}, 
	  'LATIN CAPITAL LETTER X' => 
	    { 'ord'  => '88', 
	      'hex'  => '58'}, 
	  'LATIN CAPITAL LETTER Y' => 
	    { 'ord'  => '89', 
	      'hex'  => '59'}, 
	  'LATIN CAPITAL LETTER Z' => 
	    { 'ord'  => '90', 
	      'hex'  => '5a'}, 
	  'LEFT SQUARE BRACKET' => 
	    { 'ord'  => '91', 
	      'hex'  => '5b'}, 
	  'REVERSE SOLIDUS' => 
	    { 'ord'  => '92', 
	      'hex'  => '5c'}, 
	  'RIGHT SQUARE BRACKET' => 
	    { 'ord'  => '93', 
	      'hex'  => '5d'}, 
	  'CIRCUMFLEX ACCENT' => 
	    { 'ord'  => '94', 
	      'hex'  => '5e'}, 
	  'LOW LINE' => 
	    { 'ord'  => '95', 
	      'hex'  => '5f'}, 
	  'GRAVE ACCENT' => 
	    { 'ord'  => '96', 
	      'hex'  => '60'}, 
	  'LATIN SMALL LETTER A' => 
	    { 'ord'  => '97', 
	      'hex'  => '61'}, 
	  'LATIN SMALL LETTER B' => 
	    { 'ord'  => '98', 
	      'hex'  => '62'}, 
	  'LATIN SMALL LETTER C' => 
	    { 'ord'  => '99', 
	      'hex'  => '63'}, 
	  'LATIN SMALL LETTER D' => 
	    { 'ord'  => '100', 
	      'hex'  => '64'}, 
	  'LATIN SMALL LETTER E' => 
	    { 'ord'  => '101', 
	      'hex'  => '65'}, 
	  'LATIN SMALL LETTER F' => 
	    { 'ord'  => '102', 
	      'hex'  => '66'}, 
	  'LATIN SMALL LETTER G' => 
	    { 'ord'  => '103', 
	      'hex'  => '67'}, 
	  'LATIN SMALL LETTER H' => 
	    { 'ord'  => '104', 
	      'hex'  => '68'}, 
	  'LATIN SMALL LETTER I' => 
	    { 'ord'  => '105', 
	      'hex'  => '69'}, 
	  'LATIN SMALL LETTER J' => 
	    { 'ord'  => '106', 
	      'hex'  => '6a'}, 
	  'LATIN SMALL LETTER K' => 
	    { 'ord'  => '107', 
	      'hex'  => '6b'}, 
	  'LATIN SMALL LETTER L' => 
	    { 'ord'  => '108', 
	      'hex'  => '6c'}, 
	  'LATIN SMALL LETTER M' => 
	    { 'ord'  => '109', 
	      'hex'  => '6d'}, 
	  'LATIN SMALL LETTER N' => 
	    { 'ord'  => '110', 
	      'hex'  => '6e'}, 
	  'LATIN SMALL LETTER O' => 
	    { 'ord'  => '111', 
	      'hex'  => '6f'}, 
	  'LATIN SMALL LETTER P' => 
	    { 'ord'  => '112', 
	      'hex'  => '70'}, 
	  'LATIN SMALL LETTER Q' => 
	    { 'ord'  => '113', 
	      'hex'  => '71'}, 
	  'LATIN SMALL LETTER R' => 
	    { 'ord'  => '114', 
	      'hex'  => '72'}, 
	  'LATIN SMALL LETTER S' => 
	    { 'ord'  => '115', 
	      'hex'  => '73'}, 
	  'LATIN SMALL LETTER T' => 
	    { 'ord'  => '116', 
	      'hex'  => '74'}, 
	  'LATIN SMALL LETTER U' => 
	    { 'ord'  => '117', 
	      'hex'  => '75'}, 
	  'LATIN SMALL LETTER V' => 
	    { 'ord'  => '118', 
	      'hex'  => '76'}, 
	  'LATIN SMALL LETTER W' => 
	    { 'ord'  => '119', 
	      'hex'  => '77'}, 
	  'LATIN SMALL LETTER X' => 
	    { 'ord'  => '120', 
	      'hex'  => '78'}, 
	  'LATIN SMALL LETTER Y' => 
	    { 'ord'  => '121', 
	      'hex'  => '79'}, 
	  'LATIN SMALL LETTER Z' => 
	    { 'ord'  => '122', 
	      'hex'  => '7a'}, 
	  'LEFT CURLY BRACKET' => 
	    { 'ord'  => '123', 
	      'hex'  => '7b'}, 
	  'VERTICAL LINE' => 
	    { 'ord'  => '124', 
	      'hex'  => '7c'}, 
	  'RIGHT CURLY BRACKET' => 
	    { 'ord'  => '125', 
	      'hex'  => '7d'}, 
	  'TILDE' => 
	    { 'ord'  => '126',  
	      'hex'  => '7e'}
	};

	return ($chr_map);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::CharMap (ZHex/CharMap.pm) - CharMap Module, ZHex Editor.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

The ZHex::CharMap module returns a data structure mapping unicode character 
descriptions (a description of the letter 'z' for example) to their ordinal 
values and unicode names. The following code is an example of the data stucture 
defined by the chr_map() function:

    'LATIN SMALL LETTER Z' => 
      {'ord'  => '122', 
       'hex'  => '7a'}, 

Usage:

    use ZHex::Common qw(new init_obj $VERS);
    my $objCharMap = $self->{'obj'}->{'charmap'};
    my $chr_map = $objCharMap->chr_map();
    $objCharMap->chr_map ({ 'chr_map' => $chr_map });

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 init
Method init()...
= cut

=head2 chr_map_set
Method chr_map_set()...
= cut

=head2 chr_map_ord_val
Method chr_map_ord_val()...
= cut

=head2 chr_map
Method chr_map()...
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

