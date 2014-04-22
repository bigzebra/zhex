#!/usr/bin/perl -w

package ZHex::Mouse;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     init 
     obj_init 
     check_args 
     $VERS 
     EDT_CTXT_DEFAULT 
     EDT_CTXT_INSERT 
     EDT_CTXT_SEARCH 
     SZ_READ);

BEGIN { require Exporter;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(); 
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
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'lmouse',
	     'test' => 
		[{'xpos' => 'digits'}, 
	         {'ypos' => 'digits'}] });

	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $xpos = $objEventLoop->{'evt'}->[1];
	my $ypos = $objEventLoop->{'evt'}->[2];

	my @dsp_pos;
	SEARCH_DSP_POS: 
	  foreach my $pos 
	    ($objEditor->{'edt_pos'} .. ($objEditor->{'edt_pos'} + 
	                                ($objEditor->{'sz_line'} * 
	                                 $objEditor->{'sz_column'}))) {

		my ($xc, $yc) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $pos, 
		       'edt_pos'  => $objEditor->{'edt_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		if ((($arg->{'xpos'} == ($xc + $objDisplay->{'dsp_xpad'})) || 
		     ($arg->{'xpos'} == ($xc + $objDisplay->{'dsp_xpad'} + 1))) && 
		     ($arg->{'ypos'} == ($yc + $objDisplay->{'dsp_ypad'}))) {

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

	# $self->{'CONS'}->FillAttr (($FG_BLACK | $BG_LIGHTMAGENTA), 1, $arg->{'xpos'}, $arg->{'ypos'});

	return (1); 
}

sub rmouse {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'rmouse',
	     'test' => 
		[{'xpos' => 'digits'}, 
	         {'ypos' => 'digits'}] });

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $xpos = $objEventLoop->{'evt'}->[1];
	my $ypos = $objEventLoop->{'evt'}->[2];

	$objConsole->{'CONS'}->FillAttr 
	  (($objConsole->{'FG_BLACK'} | $objConsole->{'BG_LIGHTBLUE'}), 1, $arg->{'xpos'}, $arg->{'ypos'});

	return (1);
}

sub mouse_over {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'mouse_over',
	     'test' => 
		[{'mouse_over_x'      => 'digits'}, 
	         {'mouse_over_y'      => 'digits'},
	         {'mouse_over_x_prev' => 'digits'}, 
	         {'mouse_over_y_prev' => 'digits'}] });

	my $objConsole = $self->{'obj'}->{'console'};

	# Restore original attributes to character at previous mouseover X,Y coordinate.

	$objConsole->{'CONS'}->WriteAttr 
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
	  $objConsole->{'CONS'}->ReadChar 
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
	  $objConsole->{'CONS'}->ReadAttr 
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

	$objConsole->{'CONS'}->WriteAttr 
	  (chr ($objConsole->{'FG_BLACK'} | $objConsole->{'BG_LIGHTRED'}), 
	   $arg->{'mouse_over_x'}, 
	   $arg->{'mouse_over_y'});

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::File (ZHex/Mouse.pm) - Mouse Module, ZHex Editor.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

The ZHex::Mouse module defines functions which provide...

Usage:

    use ZHex::Common qw(new init obj_init $VERS);
    my $objMouse = $self->{'obj'}->{'mouse'};
    $objMouse->lmouse();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 new
Method new()...
= cut

=head2 init
Method init()...
= cut

=head2 obj_init
Method obj_init()...
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

