#!/usr/bin/perl

package ZHex::CharMap;

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

	$self->{'chr_map'} = '';

	return (1);
}

# Functions: Character Mapping.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   chr_map_set()	...
#   chr_map()		...

sub chr_map_set {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to chr_map_set() failed, argument must be hash reference"; }

	if (! exists  $arg->{'chr_map'} || 
	    ! defined $arg->{'chr_map'} || 
	      ! (ref ($arg->{'chr_map'}) eq 'HASH')) 
		{ die "Call to chr_map_set() failed, value associated w/ key 'chr_map' must be hash reference"; }

	$self->{'chr_map'} = $arg->{'chr_map'};

	return (1);
}

sub chr_map {

	my $self = shift;

	my $chr_map = 
	  { 'NULL' => 
	    { 'byte' => '0', 
	      'hex'  => '00' }, 
	  'START OF HEADING' => 
	    { 'byte' => '1', 
	      'hex'  => '01'}, 
	  'START OF TEXT' => 
	    { 'byte' => '2', 
	      'hex'  => '02'}, 
	  'END OF TEXT' => 
	    { 'byte' => '3', 
	      'hex'  => '03'}, 
	  'END OF TRANSMISSION' => 
	    { 'byte' => '4', 
	      'hex'  => '04'}, 
	  'ENQUIRY' => 
	    { 'byte' => '5', 
	      'hex'  => '05'}, 
	  'ACKNOWLEDGE' => 
	    { 'byte' => '6', 
	      'hex'  => '06'}, 
	  'BELL' => 
	    { 'byte' => '7', 
	      'hex'  => '07'}, 
	  'BACKSPACE' => 
	    { 'byte' => '8', 
	      'hex'  => '08'}, 
	  'CHARACTER TABULATION' => 
	    { 'byte' => '9', 
	      'hex'  => '09'}, 
	  'LINE FEED (LF)' => 
	    { 'byte' => '10', 
	      'hex'  => '0a'}, 
	  'LINE TABULATION' => 
	    { 'byte' => '11', 
	      'hex'  => '0b'}, 
	  'FORM FEED (FF)' => 
	    { 'byte' => '12', 
	      'hex'  => '0c'}, 
	  'CARRIAGE RETURN (CR)' => 
	    { 'byte' => '13', 
	      'hex'  => '0d'}, 
	  'SHIFT OUT' => 
	    { 'byte' => '14', 
	      'hex'  => '0e'}, 
	  'SHIFT IN' => 
	    { 'byte' => '15', 
	      'hex'  => '0f'}, 
	  'DATA LINK ESCAPE' => 
	    { 'byte' => '16', 
	      'hex'  => '10'}, 
	  'DEVICE CONTROL ONE' => 
	    { 'byte' => '17', 
	      'hex'  => '11'}, 
	  'DEVICE CONTROL TWO' => 
	    { 'byte' => '18', 
	      'hex'  => '12'}, 
	  'DEVICE CONTROL THREE' => 
	    { 'byte' => '19', 
	      'hex'  => '13'}, 
	  'DEVICE CONTROL FOUR' => 
	    { 'byte' => '20', 
	      'hex'  => '14'}, 
	  'NEGATIVE ACKNOWLEDGE' => 
	    { 'byte' => '21', 
	      'hex'  => '15'}, 
	  'SYNCHRONOUS IDLE' => 
	    { 'byte' => '22', 
	      'hex'  => '16'}, 
	  'END OF TRANSMISSION BLOCK' => 
	    { 'byte' => '23', 
	      'hex'  => '17'}, 
	  'CANCEL' => 
	    { 'byte' => '24', 
	      'hex'  => '18'}, 
	  'END OF MEDIUM' => 
	    { 'byte' => '25', 
	      'hex'  => '19'}, 
	  'SUBSTITUTE' => 
	    { 'byte' => '26', 
	      'hex'  => '1a'}, 
	  'ESCAPE' => 
	    { 'byte' => '27', 
	      'hex'  => '1b'}, 
	  'INFORMATION SEPARATOR FOUR' => 
	    { 'byte' => '28', 
	      'hex'  => '1c'}, 
	  'INFORMATION SEPARATOR THREE' => 
	    { 'byte' => '29', 
	      'hex'  => '1d'}, 
	  'INFORMATION SEPARATOR TWO' => 
	    { 'byte' => '30', 
	      'hex'  => '1e'}, 
	  'INFORMATION SEPARATOR ONE' => 
	    { 'byte' => '31', 
	      'hex'  => '1f'}, 
	  'SPACE' => 
	    { 'byte' => '32', 
	      'hex'  => '20'}, 
	  'EXCLAMATION MARK' => 
	    { 'byte' => '33', 
	      'hex'  => '21'}, 
	  'QUOTATION MARK' => 
	    { 'byte' => '34', 
	      'hex'  => '22'}, 
	  'NUMBER SIGN' => 
	    { 'byte' => '35', 
	      'hex'  => '23'}, 
	  'DOLLAR SIGN' => 
	    { 'byte' => '36', 
	      'hex'  => '24'}, 
	  'PERCENT SIGN' => 
	    { 'byte' => '37', 
	      'hex'  => '25'}, 
	  'AMPERSAND' =>  
	    { 'byte' => '38', 
	      'hex'  => '26'}, 
	  'APOSTROPHE' =>  
	    { 'byte' => '39', 
	      'hex'  => '27'}, 
	  'LEFT PARENTHESIS' => 
	    { 'byte' => '40', 
	      'hex'  => '28'}, 
	  'RIGHT PARENTHESIS' => 
	    { 'byte' => '41', 
	      'hex'  => '29'}, 
	  'ASTERISK' => 
	    { 'byte' => '42', 
	      'hex'  => '2a'}, 
	  'PLUS SIGN' => 
	    { 'byte' => '43', 
	      'hex'  => '2b'}, 
	  'COMMA' => 
	    { 'byte' => '44', 
	      'hex'  => '2c'}, 
	  'HYPHEN-MINUS' => 
	    { 'byte' => '45', 
	      'hex'  => '2d'}, 
	  'FULL STOP' => 
	    { 'byte' => '46', 
	      'hex'  => '2e'}, 
	  'SOLIDUS' => 
	    { 'byte' => '47', 
	      'hex'  => '2f'}, 
	  'DIGIT ZERO' => 
	    { 'byte' => '48', 
	      'hex'  => '30'}, 
	  'DIGIT ONE' => 
	    { 'byte' => '49', 
	      'hex'  => '31'}, 
	  'DIGIT TWO' => 
	    { 'byte' => '50', 
	      'hex'  => '32'}, 
	  'DIGIT THREE' => 
	    { 'byte' => '51', 
	      'hex'  => '33'}, 
	  'DIGIT FOUR' => 
	    { 'byte' => '52', 
	      'hex'  => '34'}, 
	  'DIGIT FIVE' => 
	    { 'byte' => '53', 
	      'hex'  => '35'}, 
	  'DIGIT SIX' => 
	    { 'byte' => '54', 
	      'hex'  => '36'}, 
	  'DIGIT SEVEN' => 
	    { 'byte' => '55', 
	      'hex'  => '37'}, 
	  'DIGIT EIGHT' => 
	    { 'byte' => '56', 
	      'hex'  => '38'}, 
	  'DIGIT NINE' => 
	    { 'byte' => '57', 
	      'hex'  => '39'}, 
	  'COLON' => 
	    { 'byte' => '58', 
	      'hex'  => '3a'}, 
	  'SEMICOLON' => 
	    { 'byte' => '59', 
	      'hex'  => '3b'}, 
	  'LESS-THAN SIGN' => 
	    { 'byte' => '60', 
	      'hex'  => '3c'}, 
	  'EQUALS SIGN' => 
	    { 'byte' => '61', 
	      'hex'  => '3d'}, 
	  'GREATER-THAN SIGN' => 
	    { 'byte' => '62', 
	      'hex'  => '3e'}, 
	  'QUESTION MARK' => 
	    { 'byte' => '63', 
	      'hex'  => '3f'}, 
	  'COMMERCIAL AT' => 
	    { 'byte' => '64', 
	      'hex'  => '40'}, 
	  'LATIN CAPITAL LETTER A' => 
	    { 'byte' => '65', 
	      'hex'  => '41'}, 
	  'LATIN CAPITAL LETTER B' => 
	    { 'byte' => '66', 
	      'hex'  => '42'}, 
	  'LATIN CAPITAL LETTER C' => 
	    { 'byte' => '67', 
	      'hex'  => '43'}, 
	  'LATIN CAPITAL LETTER D' => 
	    { 'byte' => '68', 
	      'hex'  => '44'}, 
	  'LATIN CAPITAL LETTER E' => 
	    { 'byte' => '69', 
	      'hex'  => '45'}, 
	  'LATIN CAPITAL LETTER F' => 
	    { 'byte' => '70', 
	      'hex'  => '46'}, 
	  'LATIN CAPITAL LETTER G' => 
	    { 'byte' => '71', 
	      'hex'  => '47'}, 
	  'LATIN CAPITAL LETTER H' => 
	    { 'byte' => '72', 
	      'hex'  => '48'}, 
	  'LATIN CAPITAL LETTER I' => 
	    { 'byte' => '73', 
	      'hex'  => '49'}, 
	  'LATIN CAPITAL LETTER J' => 
	    { 'byte' => '74', 
	      'hex'  => '4a'}, 
	  'LATIN CAPITAL LETTER K' => 
	    { 'byte' => '75', 
	      'hex'  => '4b'}, 
	  'LATIN CAPITAL LETTER L' => 
	    { 'byte' => '76', 
	      'hex'  => '4c'}, 
	  'LATIN CAPITAL LETTER M' => 
	    { 'byte' => '77', 
	      'hex'  => '4d'},
	  'LATIN CAPITAL LETTER N' => 
	    { 'byte' => '78', 
	      'hex'  => '4e'}, 
	  'LATIN CAPITAL LETTER O' => 
	    { 'byte' => '79', 
	      'hex'  => '4f'}, 
	  'LATIN CAPITAL LETTER P' => 
	    { 'byte' => '80', 
	      'hex'  => '50'}, 
	  'LATIN CAPITAL LETTER Q' => 
	    { 'byte' => '81', 
	      'hex'  => '51'}, 
	  'LATIN CAPITAL LETTER R' => 
	    { 'byte' => '82', 
	      'hex'  => '52'}, 
	  'LATIN CAPITAL LETTER S' => 
	    { 'byte' => '83', 
	      'hex'  => '53'}, 
	  'LATIN CAPITAL LETTER T' => 
	    { 'byte' => '84', 
	      'hex'  => '54'}, 
	  'LATIN CAPITAL LETTER U' => 
	    { 'byte' => '85', 
	      'hex'  => '55'}, 
	  'LATIN CAPITAL LETTER V' => 
	    { 'byte' => '86', 
	      'hex'  => '56'}, 
	  'LATIN CAPITAL LETTER W' => 
	    { 'byte' => '87', 
	      'hex'  => '57'}, 
	  'LATIN CAPITAL LETTER X' => 
	    { 'byte' => '88', 
	      'hex'  => '58'}, 
	  'LATIN CAPITAL LETTER Y' => 
	    { 'byte' => '89', 
	      'hex'  => '59'}, 
	  'LATIN CAPITAL LETTER Z' => 
	    { 'byte' => '90', 
	      'hex'  => '5a'}, 
	  'LEFT SQUARE BRACKET' => 
	    { 'byte' => '91', 
	      'hex'  => '5b'}, 
	  'REVERSE SOLIDUS' => 
	    { 'byte' => '92', 
	      'hex'  => '5c'}, 
	  'RIGHT SQUARE BRACKET' => 
	    { 'byte' => '93', 
	      'hex'  => '5d'}, 
	  'CIRCUMFLEX ACCENT' => 
	    { 'byte' => '94', 
	      'hex'  => '5e'}, 
	  'LOW LINE' => 
	    { 'byte' => '95', 
	      'hex'  => '5f'}, 
	  'GRAVE ACCENT' => 
	    { 'byte' => '96', 
	      'hex'  => '60'}, 
	  'LATIN SMALL LETTER A' => 
	    { 'byte' => '97', 
	      'hex'  => '61'}, 
	  'LATIN SMALL LETTER B' => 
	    { 'byte' => '98', 
	      'hex'  => '62'}, 
	  'LATIN SMALL LETTER C' => 
	    { 'byte' => '99', 
	      'hex'  => '63'}, 
	  'LATIN SMALL LETTER D' => 
	    { 'byte' => '100', 
	      'hex'  => '64'}, 
	  'LATIN SMALL LETTER E' => 
	    { 'byte' => '101', 
	      'hex'  => '65'}, 
	  'LATIN SMALL LETTER F' => 
	    { 'byte' => '102', 
	      'hex'  => '66'}, 
	  'LATIN SMALL LETTER G' => 
	    { 'byte' => '103', 
	      'hex'  => '67'}, 
	  'LATIN SMALL LETTER H' => 
	    { 'byte' => '104', 
	      'hex'  => '68'}, 
	  'LATIN SMALL LETTER I' => 
	    { 'byte' => '105', 
	      'hex'  => '69'}, 
	  'LATIN SMALL LETTER J' => 
	    { 'byte' => '106', 
	      'hex'  => '6a'}, 
	  'LATIN SMALL LETTER K' => 
	    { 'byte' => '107', 
	      'hex'  => '6b'}, 
	  'LATIN SMALL LETTER L' => 
	    { 'byte' => '108', 
	      'hex'  => '6c'}, 
	  'LATIN SMALL LETTER M' => 
	    { 'byte' => '109', 
	      'hex'  => '6d'}, 
	  'LATIN SMALL LETTER N' => 
	    { 'byte' => '110', 
	      'hex'  => '6e'}, 
	  'LATIN SMALL LETTER O' => 
	    { 'byte' => '111', 
	      'hex'  => '6f'}, 
	  'LATIN SMALL LETTER P' => 
	    { 'byte' => '112', 
	      'hex'  => '70'}, 
	  'LATIN SMALL LETTER Q' => 
	    { 'byte' => '113', 
	      'hex'  => '71'}, 
	  'LATIN SMALL LETTER R' => 
	    { 'byte' => '114', 
	      'hex'  => '72'}, 
	  'LATIN SMALL LETTER S' => 
	    { 'byte' => '115', 
	      'hex'  => '73'}, 
	  'LATIN SMALL LETTER T' => 
	    { 'byte' => '116', 
	      'hex'  => '74'}, 
	  'LATIN SMALL LETTER U' => 
	    { 'byte' => '117', 
	      'hex'  => '75'}, 
	  'LATIN SMALL LETTER V' => 
	    { 'byte' => '118', 
	      'hex'  => '76'}, 
	  'LATIN SMALL LETTER W' => 
	    { 'byte' => '119', 
	      'hex'  => '77'}, 
	  'LATIN SMALL LETTER X' => 
	    { 'byte' => '120', 
	      'hex'  => '78'}, 
	  'LATIN SMALL LETTER Y' => 
	    { 'byte' => '121', 
	      'hex'  => '79'}, 
	  'LATIN SMALL LETTER Z' => 
	    { 'byte' => '122', 
	      'hex'  => '7a'}, 
	  'LEFT CURLY BRACKET' => 
	    { 'byte' => '123', 
	      'hex'  => '7b'}, 
	  'VERTICAL LINE' => 
	    { 'byte' => '124', 
	      'hex'  => '7c'}, 
	  'RIGHT CURLY BRACKET' => 
	    { 'byte' => '125', 
	      'hex'  => '7d'}, 
	  'TILDE' => 
	    { 'byte' => '126', 
	      'hex'  => '7e'}
	};

	return ($chr_map);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::CharMap (ZHex/CharMap.pm) - CharMap Module, ZebraHex Editor.


=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The ZHex::CharMap module maps characters ('z' for example) to their 
ordinal values and unicode names. The following code is an example of 
the data structure defined by the chr_map() function:

	  'LATIN SMALL LETTER Z' => 
	    { 'byte' => '122', 
	      'hex'  => '7a'}, 

Usage:

    use ZHex;

    my $editorObj = ZHex->new();
    ...

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS


=head2 chr_map
Method chr_map()...
= cut

=head2 chr_map_set
Method chr_map_set()...
= cut

=head2 init
Method init()...
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

