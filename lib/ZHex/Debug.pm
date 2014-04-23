#!/usr/bin/perl -w

package ZHex::Debug;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     init 
     init_obj 
     init_child_obj 
     check_args 
     errmsg 
     ZHEX_VERSION);

use constant DBG_LEVEL => 1;

BEGIN { require Exporter;
	our $VERSION   = ZHEX_VERSION;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(); 
}

# Functions: Format debugging information for display console.
#
#   _____________		___________
#   Function Name		Description
#   _____________		___________
#   dbg_box()			Returns a title + list of key/value pairs formatted for 
#                               display console. Used by the rest of the dbg_* functions.
#   dbg_mouse_evt()		Returns debugging information: mouse events.
#   dbg_keybd_evt()		Returns debugging information: keyboard events.
#   dbg_unmatched_evt()		Returns debugging information: unmatched events.
#   dbg_curs()			Returns debugging information: editor cursor.
#   dbg_display()		Returns debugging information: display.
#   dbg_count()			Returns debugging information: event counters.
#   dbg_console()		Returns debugging information: Win32 console.

sub dbg_box {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'dbg_box',
	     'test' => 
		[{'title' => 'string'}, 
	         {'pairs' => 'hashref'}] });

	my $max_len_key = 0;
	my $max_len_val = 0;
	foreach my $key (keys %{ $arg->{'pairs'} }) {

		if ($max_len_key < (length ($key))) 
			{ $max_len_key = (length ($key)); }

		if ($max_len_val < (length ($arg->{'pairs'}->{$key}))) 
			{ $max_len_val = (length ($arg->{'pairs'}->{$key})); }
	}

	my $fmt_str_t = 
	  '%-' . ($max_len_key + $max_len_val + 1) . 
	   '.' . ($max_len_key + $max_len_val + 1) . 's';

	my $fmt_str = 
	  '%-' . $max_len_key . '.' . $max_len_key . 's ' . 
	  '%-' . $max_len_val . '.' . $max_len_val . 's';

	my $dbg = [];

	push @{ $dbg }, 
	     sprintf ($fmt_str_t, $arg->{'title'});   # Title.

	foreach my $key (sort keys %{ $arg->{'pairs'} }) 
		{ push @{ $dbg }, 
		       sprintf ($fmt_str, $key, $arg->{'pairs'}->{$key}); }   # Key/value pair.

	return ($dbg);
}

sub dbg_mouse_evt {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'dbg_mouse_evt',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Display mouse event debugging information: 
	#   Character block area (17 chars wide x 10 chars high).

	if (! defined $arg->{'evt'}->[0] || 
	             ($arg->{'evt'}->[0] eq '') || 
	    !        ($arg->{'evt'}->[0] ==  2) ||          # Event Type: 2 (mouse event)
	    ! defined $arg->{'evt'}->[3] || 
	             ($arg->{'evt'}->[3] eq '') || 
	    !       (($arg->{'evt'}->[3] ==  0) ||          # Button State:  0 (no    mouse button)
	             ($arg->{'evt'}->[3] ==  1) ||          # Button State:  1 (left  mouse button)
	             ($arg->{'evt'}->[3] ==  2) ||          # Button State:  2 (right mouse button)
	           ((($arg->{'evt'}->[3] ==  7864320) ||    # Button State:  7864320 (mouse wheel roll upward)
                     ($arg->{'evt'}->[3] == -7864320)) &&   # Button State: -7864320 (mouse wheel roll downward)
	      defined $arg->{'evt'}->[5] && 
	           ! ($arg->{'evt'}->[5] eq '') && 
	             ($arg->{'evt'}->[5] ==  4)))) {

		return (undef);
	}

	# Generate formatted string indicating if X,Y coordinate has 
	# changed.
	#
	#   NOTE: X,Y coordinate of character in console display (which 
	#         mouse is over the top of).
	#   NOTE: This is not X,Y coordinate in pixels, this is X,Y 
	#         coordinate in console display characters.

	my $chg_state;
	if (defined $arg->{'evt'}->[1] && 
	           ($arg->{'evt'}->[1] == $objEventLoop->{'mouse_over_x'}) && 
	    defined $arg->{'evt'}->[2] && 
	           ($arg->{'evt'}->[2] == $objEventLoop->{'mouse_over_y'})) 
	     { $chg_state = 'Same'; }      # X,Y Changed? NO:  Mouse hasn't moved enough to change the X,Y coordinates.
	else { $chg_state = 'Changed'; }   # X,Y Changed? YES: Mouse moved enough to change one (or both) X,Y values.

	my $title = 'MOUSE_EVENT_DEBUG';

	my $pairs = 
	  {'EvntType' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[0] ? $arg->{'evt'}->[0] : '<empty>'; }), 
	   'MousPosX' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[1] ? $arg->{'evt'}->[1] : '<empty>'; }), 
	   'MousPosY' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[2] ? $arg->{'evt'}->[2] : '<empty>'; }), 
	   'BtnState' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[3] ? $arg->{'evt'}->[3] : '<empty>'; }), 
	   'CtlrKeyS' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[4] ? $arg->{'evt'}->[4] : '<empty>'; }), 
	   'EvntFlag' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[5] ? $arg->{'evt'}->[5] : '<empty>'; }), 
	   'ChangeXY' => sprintf("%8.8s", $chg_state), 
	   'MousChar' => sprintf("%8.8s", $objEventLoop->{'mouse_over_char'}), 
	   'PrevChar' => sprintf("%8.8s", $objEventLoop->{'mouse_over_char'})};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_keybd_evt {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'dbg_keybd_evt',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	# Display keyboard event debugging information: 
	#   Character block area (17 chars wide x 8 chars high).

	if (! defined $arg->{'evt'}->[0] || 
	             ($arg->{'evt'}->[0] eq '') || 
	    ! defined $arg->{'evt'}->[1] || 
	             ($arg->{'evt'}->[1] eq '') || 
	           ! ($arg->{'evt'}->[0] == 1) ||   # Event_Type: 1 (keyboard event).
	           ! ($arg->{'evt'}->[1] == 1)) {   # Key_Down:   1 (key pressed).

		return (undef);
	}

	my $title = 'KEYBOARD_EVNT_DBG';

	my $pairs = 
	  {'EvntType' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[0] ? $arg->{'evt'}->[0] : '<empty>'; }), 
	   'KeyDown?' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[1] ? $arg->{'evt'}->[1] : '<empty>'; }), 
	   'RptCount' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[2] ? $arg->{'evt'}->[2] : '<empty>'; }), 
	   'VirKCode' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[3] ? $arg->{'evt'}->[3] : '<empty>'; }), 
	   'VirSCode' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[4] ? $arg->{'evt'}->[4] : '<empty>'; }), 
	   'CharCode' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[5] ? $arg->{'evt'}->[5] : '<empty>'; }), 
	   'CtrlKeyS' => sprintf("%8.8s", eval { defined $arg->{'evt'}->[6] ? $arg->{'evt'}->[6] : '<empty>'; })};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_unmatched_evt {

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'dbg_unmatched_evt',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	# Display unmatched event debug info: 
	#   Character block area (17 chars wide x 8 chars high).

	my @lbl;
	if (defined $arg->{'evt'}->[0] && 
	         ! ($arg->{'evt'}->[0] eq '') && 
	            $arg->{'evt'}->[0] == 1) {

		@lbl = 
		  ('EvntType',    # 1
		   'KeyDown?',    # 2
		   'RptCount',    # 3
		   'VirtKeyC',    # 4
		   'VirtScnC',    # 5
		   'CharCode',    # 6
		   'CtrlKeyS');   # 7
	}
	elsif (defined $arg->{'evt'}->[0] && 
	            ! ($arg->{'evt'}->[0] eq '') && 
	               $arg->{'evt'}->[0] == 2) {

		@lbl = 
		  ('EvntType',    # 1
		   'MousPosX',    # 2
		   'MousPosY',    # 3
		   'BtnState',    # 4
		   'CtrlKeyS',    # 5
		   'EvntFlag',    # 6
		   '<empty> ');   # 7
	}
	else {

		@lbl = 
		  ('<empty> ',    # 1
		   '<empty> ',    # 2
		   '<empty> ',    # 3
		   '<empty> ',    # 4
		   '<empty> ',    # 5
		   '<empty> ',    # 6
		   '<empty> ');   # 7
	}

	my $title = 'UNMATCHED_EVT_DBG';

	my $pairs = 
	  {$lbl[0] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[0] ? $arg->{'evt'}->[0] : '<empty>'; }), 
	   $lbl[1] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[1] ? $arg->{'evt'}->[1] : '<empty>'; }), 
	   $lbl[2] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[2] ? $arg->{'evt'}->[2] : '<empty>'; }), 
	   $lbl[3] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[3] ? $arg->{'evt'}->[3] : '<empty>'; }), 
	   $lbl[4] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[4] ? $arg->{'evt'}->[4] : '<empty>'; }), 
	   $lbl[5] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[5] ? $arg->{'evt'}->[5] : '<empty>'; }),
	   $lbl[6] => sprintf("%8.8s", eval { defined $arg->{'evt'}->[6] ? $arg->{'evt'}->[6] : '<empty>'; })};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_curs {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'display'}->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'display'}->{'obj'}->{'editor'};

	# Display cursor debugging information: 
	#   Character block area (23 chars wide x 5 chars high).

	my $curs_edge_status = '';
	if ($objCursor->{'curs_ctxt'} =~ /^[012]$/) {

		if (($objCursor->{'curs_pos'} >= $objEditor->{'edt_pos'}) && 
		    ($objCursor->{'curs_pos'} < ($objEditor->{'edt_pos'} + $objEditor->{'sz_line'}))) 
			{ $curs_edge_status = 'TOP'; }
		elsif ( ($objCursor->{'curs_pos'} >= 
		          ($objEditor->{'edt_pos'} + 
		             ($objEditor->{'sz_line'} * $objEditor->{'sz_column'}) - $objEditor->{'sz_line'})) && 
		        ($objCursor->{'curs_pos'} < 
		           ($objEditor->{'edt_pos'} + 
		              ($objEditor->{'sz_line'} * $objEditor->{'sz_column'}))) ) 
			{ $curs_edge_status = 'BOTTOM'; }
		else    { $curs_edge_status = 'MIDDLE'; }
	}
	else { $curs_edge_status = 'NONCTXT'; }

	my $title = 'CURSOR__INFO__DEBUG';

	my $pairs = 
	  {'CursorPosition' => sprintf("%8.8s", $objCursor->{'curs_pos'}), 
	   'CursorContext ' => sprintf("%8.8s", $objCursor->{'curs_ctxt'}),
	   'CursorUpdates ' => sprintf("%8.8s", $objCursor->{'ct_display_curs'}),
	   'CursorEdgeStat' => sprintf("%8.8s", $curs_edge_status)};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_display {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};
	my $objEditor  = $self->{'obj'}->{'display'}->{'obj'}->{'editor'};
	my $objFile    = $self->{'obj'}->{'file'};

	# Display display event debug info: 
	#   Character block area (25 chars wide x 12 chars high).

	# Calculate total number of lines based upon file size.

	my $lines = ($objFile->file_len() / $objEditor->{'sz_line'});
	if ($lines =~ s/\.\d+?$//) 
	  { $lines++; }

	# Caluculate greatest possible value of dsp_pos.

	my $dsp_pos_lowest = (($lines * $objEditor->{'sz_line'}) - ($objEditor->{'sz_line'} * $objEditor->{'sz_column'}));

	my $title = 'DISPLAY_POSITION_DEBUG';

	my $pairs = 
	  {'DisplayPosition ' => sprintf ("%8.8s", $objEditor->{'edt_pos'}), 
	   'TotalFileLines  ' => sprintf ("%8.8s", $lines), 
	   'DisplayLowestPos' => sprintf ("%8.8s", $dsp_pos_lowest), 
	   'FileSize        ' => sprintf ("%8.8s", $objFile->file_len()), 
	   'DisplayHeight   ' => sprintf ("%8.8s", $objDisplay->{'d_height'}), 
	   'DisplayWidth    ' => sprintf ("%8.8s", $objDisplay->{'d_width'}), 
	   'DisplayXPadding ' => sprintf ("%8.8s", $objDisplay->{'dsp_xpad'}), 
	   'DisplayYPadding ' => sprintf ("%8.8s", $objDisplay->{'dsp_ypad'}), 
	   'EditorSizeColumn' => sprintf ("%8.8s", $objEditor->{'sz_column'}), 
	   'EditorSizeLine  ' => sprintf ("%8.8s", $objEditor->{'sz_line'}), 
	   'FileLengthBytes ' => sprintf ("%8.8s", $objFile->file_len()) };

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_count {

	my $self = shift;

	my $objEditor    = $self->{'obj'}->{'display'}->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	$objEventLoop->{'ct_evt_total'}++;

	# Display event counters debugging information: 
	#   Character block area (19 chars wide x 4 chars high).

	my $title = 'EVENT_COUNT_DEBUG';

	my $pairs = 
	  {'ttl_evnt  ' => sprintf ("%8.8s", $objEventLoop->{'ct_evt_total'}),
	   'funcevnt  ' => sprintf ("%8.8s", $objEventLoop->{'ct_evt_functional'}), 
	   'event ctxt' => sprintf ("%8.8s", $objEditor->{'edt_ctxt'})};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

sub dbg_console {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	# Display console debugging information: 
	#   Character block area (19 chars wide x 8 chars high).

	my $title = 'CONSOLE_DEBUG';

	my $pairs = 
	  {'OrgAttrs' => sprintf ("%10.10s",      $objConsole->{'w32cons_attr_orig'}), 
	   'CurSzBuf' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_buf_cols'},      $objConsole->{'w32cons_buf_rows'}),
	   'OrgSzBuf' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_buf_cols_orig'}, $objConsole->{'w32cons_buf_rows_orig'}), 
	   'MaxSzWin' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_buf_cols_max'},  $objConsole->{'w32cons_buf_rows_max'}), 
	   'CursrPos' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_curs_xpos'},     $objConsole->{'w32cons_curs_ypos'}), 
	   'UprLfPos' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_first_col'},     $objConsole->{'w32cons_top_row'}), 
	   'LwrRtPos' => sprintf ("%4.4s, %4.4s", $objConsole->{'w32cons_last_col'},      $objConsole->{'w32cons_bottom_row'})};

	my $dbg = 
	  $self->dbg_box 
	    ({ 'title' => $title, 
	       'pairs' => $pairs });

	return ($dbg);
}

# Functions: Error message display/debugging.
#
#   ____		___________
#   NAME		DESCRIPTION
#   ____		___________
#   errmsg_handler()	Establish handlers for calls to warn() and die().
#   errmsg()		Error message handler/wrapper.
#   errmsg_queue()	Returns an array containing the last 10 error messages (formatted for the display console).

sub errmsg_handler {

	my $self = shift;

	# Establish handler for filtering "warn" messages.

	$SIG{__WARN__} = 
	  sub { 

		if (scalar (@_) == 1)
		     { @_ = split (/\.\s/, $_[0]); }

		if (defined $self) {

			$self->errmsg (@_);
		}
		
		if (! (defined $self) || 
		      (DBG_LEVEL > 0)) {

			foreach my $msg (@_) { print STDERR $msg . "\n"; }
		}
	  };
	  # End SIG WARN handler

	# Establish handler for filtering "die" messages.

	$SIG{__DIE__} = 
	  sub {

		if (defined $self) {

			$self->errmsg (@_);
		}

		if (! (defined $self) || 
		      (DBG_LEVEL > 0)) {

			foreach my $msg (@_) { print STDERR $msg . "\n"; } 
		}

		exit (0);
	  };
	  # End SIG DIE handler

	return (1);
}

sub errmsg_queue {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};

	# If errmsg_queue contains less than e_height items: fill it with blank lines full of spaces.

	while (! exists  $self->{'errmsg_queue'} || 
	       ! defined $self->{'errmsg_queue'} || 
	     (scalar (@{ $self->{'errmsg_queue'} }) < 
	        $objDisplay->{'d_elements'}->{'errmsg_queue'}->{'e_height'})) {

		unshift @{ $self->{'errmsg_queue'} }, (' ' x $objDisplay->{'d_elements'}->{'errmsg_queue'}->{'e_width'});
	}

	# Limit the error message queue to a maximum of x messages (the height of it's container).

	while (scalar (@{ $self->{'errmsg_queue'} }) > 
	         $objDisplay->{'d_elements'}->{'errmsg_queue'}->{'e_height'}) {

		shift @{ $self->{'errmsg_queue'} };
	}

	return ($self->{'errmsg_queue'});
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::Debug (ZHex/Debug.pm) - Debug Module, ZHex Editor.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

The ZHex::Debug module defines functions which provide debugging 
information as display elements (for use within the hex editor display) 
Used for development/debugging purposes.

Usage:

    use ZHex::Common qw(new init_obj $VERS);
    my $objDebug = $self->{'obj'}->{'debug'};
    $objDebug->errmsg ("This error message to be displayed inside editor.");

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 dbg_box
Method dbg_box()...
= cut

=head2 dbg_console
Method dbg_console()...
= cut

=head2 dbg_count
Method dbg_count()...
= cut

=head2 dbg_curs
Method dbg_curs()...
= cut

=head2 dbg_display
Method dbg_display()...
= cut

=head2 dbg_keybd_evt
Method dbg_keybd_evt()...
= cut

=head2 dbg_mouse_evt
Method dbg_mouse_evt()...
= cut

=head2 dbg_unmatched_evt
Method dbg_unmatched_evt()...
= cut

=head2 errmsg_handler
Method errmsg_handler()...
= cut

=head2 errmsg_queue
Method errmsg_queue()...
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

