#!/usr/bin/perl

package ZHex;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::BoilerPlate qw(new init obj_init $VERS);
use ZHex::CharMap;
use ZHex::Console;
use ZHex::Cursor;
use ZHex::Debug;
use ZHex::Display;
use ZHex::Editor;
use ZHex::Event;
use ZHex::EventLoop;
use ZHex::File;

use Getopt::Long;

BEGIN { require Exporter;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(); 
}

sub init_config_main {

	my $self = shift;

	$self->{'cfg'} = {};   # User configurable settings stored here...

	# ______________________________
	# Member variables (Console.PM).

	$self->{'cfg'}->{'w32cons_title'} = 
	  'ZHex - ZebraHex Editor (v0.01) (03/12/2014) (by Double Z)';

	# ______________________________
	# Member variables (Editor.PM).

	$self->{'cfg'}->{'dsp_pos'}    =   0;   # The first character (byte number) appearing at top/left of hex editor display.
	$self->{'cfg'}->{'sz_word'}    =   4;   # Size: width (in characters) of a word.
	$self->{'cfg'}->{'sz_line'}    =  16;   # Size: width (in characters) of a line.
	$self->{'cfg'}->{'sz_column'}  =  50;   # Size: height (in lines) of a column.
	$self->{'cfg'}->{'horiz_rule'} = '|';   # Word seperator: a vertical line used in display for readability.
	$self->{'cfg'}->{'oob_char'}   = '-';   # Out-of-bounds character: displayed in place of non-displayable characters. 

	# ______________________________
	# Member variables (Display.PM).

	$self->{'cfg'}->{'dsp_xpad'}   =  2;   # "X" padding (horizontal).
	$self->{'cfg'}->{'dsp_ypad'}   =  2;   # "Y" padding (vertical).
	$self->{'cfg'}->{'d_width'}    = ''; 
	$self->{'cfg'}->{'d_height'}   = '';
	$self->{'cfg'}->{'d_elements'} = '';
	$self->{'cfg'}->{'c_elements'} = '';
	$self->{'cfg'}->{'dsp'}        = '';
	$self->{'cfg'}->{'dsp_prev'}   = '';

	# ______________________________
	# ...

	return (1);
}

sub set_accessors_main {

	my $self = shift;

	# Call object member variable's accessor methods to set initial 
	# values.

	$self->{'obj'}->{'editor'}->set_dsp_pos 
	  ({ 'dsp_pos' => $self->{'cfg'}->{'dsp_pos'} });

	$self->{'obj'}->{'editor'}->set_sz_word 
	  ({ 'sz_word' => $self->{'cfg'}->{'sz_word'} });

	$self->{'obj'}->{'editor'}->set_sz_line 
	  ({ 'sz_line' => $self->{'cfg'}->{'sz_line'} });

	$self->{'obj'}->{'editor'}->set_sz_column 
	  ({ 'sz_column' => $self->{'cfg'}->{'sz_column'} });

	#   $self->{'cfg'}->{'dsp_xpad'}
	#   $self->{'cfg'}->{'dsp_ypad'}
	#   $self->{'cfg'}->{'w32cons_title'}

	return (1);
}

sub init_cli_opts_main {

	my $self = shift;

	# Process command line arguments.
	#
	#   Long Opt	Abbreviation
	#   ________	____________
	#   --dbg	-v
	#   --filename	-f
	#   --help	 ?

	my $opt = {};
	PROCESS_COMMAND_LINE_OPTIONS: {

		# Define keys in the %opt hash, based on command line options.
		#
		#   KEY		DESCRIPTION 
		#   ___		___________ 
		#   cla_dbg	Debug Info Output Argument (Command Line Option) 
		#   cla_fn	Filename Argument (Command Line Option) 
		#   cla_help	Help Argument (Command Line Option) 

		$opt->{'cla_dbg'}  = '';
		$opt->{'cla_fn'}   = '';
		$opt->{'cla_help'} = '';

		if (my $rv = 
		  GetOptions 
		    ('dbg|v=i{1,1}'      => \$opt->{'cla_dbg'}, 
		     'filename|n=s{1,1}' => \$opt->{'cla_fn'}, 
		     'help|?'            => \$opt->{'cla_help'})) {

			my ($cla_dbg_str, 
			    $cla_fn_str, 
			    $cla_help_str);

			if ($opt->{'cla_dbg'} eq '') 
			     { $cla_dbg_str = '<empty>'; }
			else { $cla_dbg_str = $opt->{'cla_dbg'}; }

			if ($opt->{'cla_fn'} eq '') 
			     { $cla_fn_str = '<empty>'; }
			else { $cla_fn_str = $opt->{'cla_fn'}; }

			if ($opt->{'cla_help'} eq '') 
			     { $cla_help_str = '<empty>'; }
			else { $cla_help_str = $opt->{'cla_help'}; }

			if (($opt->{'cla_dbg'} ne '') && ($opt->{'cla_dbg'} > 0)) {

				print 
				  "Summary of command line arguments:  \n" . 
				  "  --dbg      '" . $cla_dbg_str  . "'\n" . 
				  "  --filename '" . $cla_fn_str   . "'\n" . 
				  "  --help     '" . $cla_help_str . "'\n\n";
			}
			else {

				$opt->{'cla_dbg'} = 0;
			}
		}
		else {

			die "Call to GetOptions() returned w/ failure. " . 
			    "Unable to process command line options. " . $! . ", " . $^E;
		}
	}

	# Display help message and exit (if --help flag was used, or no --filename provided).

	if ($opt->{'cla_help'} || 
	    ! (-f $opt->{'cla_fn'})) {

		$self->display_help_msg();
		exit (0);
	}

	$self->{'opt'} = $opt;

	return (1);
}

sub init_objects_main {

	my $self = shift;

	my $obj;
	INIT_OBJECTS: {

		# Initialize objects provided by modules.
		# Store references to all objects in obj hash.
		# Store reference to obj hash in each object.

		$obj = 
		  { 'charmap'   => ZHex::CharMap->new(), 
		    'console'   => ZHex::Console->new(), 
		    'cursor'    => ZHex::Cursor->new(), 
		    'debug'     => ZHex::Debug->new(), 
		    'display'   => ZHex::Display->new(), 
		    'editor'    => ZHex::Editor->new(), 
		    'event'     => ZHex::Event->new(), 
		    'eventloop' => ZHex::EventLoop->new(), 
		    'file'      => ZHex::File->new() };

		foreach my $module (sort keys %{ $obj }) {

			if (! $obj->{$module}->obj_init ({ 'obj' => $obj })) 
			  { die "Call to obj_init() within module '" . $module . "' returned w/ failure"; }
		}
	}

	$self->{'obj'} = {};
	$self->{'obj'} = $obj;

	return (1);
}

sub run {

	my $self = shift;

	OPEN_AND_READ_FILE: {

		# Open, stat, and read file from filesystem.
		#   1) Verify that file exists on filesystem.
		#   2) Store file name (inside "file" object, using set_file() method).
		#   3) Stat file (system call, returns w/ file attributes).
		#   4) Read file into memory.

		if (! ($self->{'obj'}->{'file'}->check_file ({ 'fn' => $self->{'opt'}->{'cla_fn'} }))) 
			{ die "Call to check_file() returned w/ failure"; }

		if (! ($self->{'obj'}->{'file'}->set_file   ({ 'fn' => $self->{'opt'}->{'cla_fn'} }))) 
			{ die "Call to set_file() returned w/ failure"; }

		if (! ($self->{'obj'}->{'file'}->stat_file  ({ 'fn' => $self->{'opt'}->{'cla_fn'} }))) 
			{ die "Call to stat_file() returned w/ failure"; }

		if (! ($self->{'obj'}->{'file'}->read_file  ({ 'fn' => $self->{'opt'}->{'cla_fn'} }))) 
			{ die "Call to read_file() returned w/ failure"; }
	}

	INIT_W32_CONSOLE: {

		# Initialize the system console:
		#
		#   1) Initialize console object.
		#   2) Store terminal settings/characteristics.
		#   3) Store value of display console title.

		if (! ($self->{'obj'}->{'console'}->w32cons_init())) 
			{ die "Call to w32cons_init() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_termcap())) 
			{ die "Call to w32cons_termcap() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_title_get())) 
			{ die "Call to w32cons_title_get() returned w/ failure"; }

		# Prepare the display console for editor display:
		#
		#   1) Update display console title.
		#   2) Clear  display console.
		#   3) Set    display console to white text on black background.
		#   4) Set    Win32   console cursor to invisible.
		#   5) Move   Win32   console cursor to top left corner.
		
		if (! ($self->{'obj'}->{'console'}->w32cons_title_set 
			({ 'w32cons_title' => $self->{'cfg'}->{'w32cons_title'} }))) 
			{ die "Call to w32cons_title_set() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_mode_set())) 
			{ die "Call to w32cons_mode_set() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_clear())) 
			{ die "Call to w32cons_clear() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_fg_white_bg_black())) 
			{ die "Call to w32cons_fg_white_bg_black() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_cursor_invisible())) 
			{ die "Call to w32cons_cursor_invisible() returned w/ failure"; }

		if (! ($self->{'obj'}->{'console'}->w32cons_cursor_tleft_dsp())) 
			{ die "Call to w32cons_cursor_tleft_dsp() returned w/ failure"; }
	}

	INIT_EDITOR_DISPLAY: {

		# Initialize the editor display.
		#   1) Set width/height of editor display.
		#   2) Set vertical/horizontal padding (space at the top/left of editor display).
		#   3) Initialize/store (blank) display_prev array.

		$self->{'obj'}->{'display'}->dimensions_set 
		  ({ 'd_width'  => (($self->{'obj'}->{'console'}->{'w32cons_last_col'} + 1) - 
		                     $self->{'cfg'}->{'dsp_xpad'}), 
		     'd_height' => (($self->{'obj'}->{'console'}->{'w32cons_bottom_row'} + 1) - 
		                     $self->{'cfg'}->{'dsp_ypad'}) });

		$self->{'obj'}->{'display'}->padding_set 
		  ({ 'dsp_ypad' => $self->{'cfg'}->{'dsp_ypad'}, 
		     'dsp_xpad' => $self->{'cfg'}->{'dsp_xpad'} });

		$self->{'obj'}->{'display'}->dsp_prev_set 
		  ({ 'dsp_prev' => 
			$self->{'obj'}->{'display'}->dsp_prev_init 
			  ({ 'd_width'  => $self->{'obj'}->{'display'}->{'d_width'}, 
			     'd_height' => $self->{'obj'}->{'display'}->{'d_height'} }) });

		# Initialize editor display.
		#   1) Initialize editor display elements: 
		#        X,Y coordinates within display, padding, enabled.
		#   2) Initialize colorization elements.
		#        Associate them with editor display element.
		#   3) Store references to: 
		#        Display elements data structure, 
		#        Colorization elements data structure.
		#   4) Initialize content of display elements: 'e_contents' 
		#      (key/value pair, container for content of each display 
		#      element).

		$self->{'obj'}->{'display'}->d_elements_set 
		  ({ 'd_elements' => $self->{'obj'}->{'display'}->d_elements_init() });

		$self->{'obj'}->{'display'}->c_elements_set 
		  ({ 'c_elements' => $self->{'obj'}->{'display'}->c_elements_init() });
	}

	WRITE_EDITOR_DISPLAY_TO_CONSOLE: {

		# 1) Generate the editor display, store within display object 
		#    under key 'display' (confusing choice of variable names,  
		#    I know).
		# 2) Write editor display to display console.

		$self->{'obj'}->{'display'}->dsp_set 
		  ({ 'dsp' => $self->{'obj'}->{'display'}->generate_editor_display() });

		$self->{'obj'}->{'console'}->w32cons_refresh_display 
		  ({ 'dsp'      => $self->{'obj'}->{'display'}->{'dsp'}, 
		     'dsp_prev' => $self->{'obj'}->{'display'}->{'dsp_prev'}, 
		     'dsp_xpad' => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad' => $self->{'obj'}->{'display'}->{'dsp_ypad'} });

		# 1) Colorize elements of the editor display.
		# 2) Highlight the cursor within the editor display.

		$self->{'obj'}->{'console'}->colorize_display 
		  ({ 'c_elements' => $self->{'obj'}->{'display'}->active_c_elements(), 
		     'dsp_xpad'   => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad'   => $self->{'obj'}->{'display'}->{'dsp_ypad'} });

		$self->{'obj'}->{'cursor'}->curs_display 
		  ({ 'dsp_xpad' => $self->{'obj'}->{'display'}->{'dsp_xpad'}, 
		     'dsp_ypad' => $self->{'obj'}->{'display'}->{'dsp_ypad'}, 
		     'force'    => 0});
	}

	INSTALL_ERROR_MESSAGE_HANDLER: {

		$self->{'obj'}->{'debug'}->errmsg_handler();
	}

	LOAD_CHARACTER_MAP_DATA_STRUCTURE: {

		$self->{'obj'}->{'charmap'}->chr_map_set 
		  ({ 'chr_map' => $self->{'obj'}->{'charmap'}->chr_map() });
	}

	PROCESS_EVENTS_IN_MAIN_EVENT_LOOP: {

		# 1) Register event handler callback subroutines.
		# 2) Enter event loop.

		$self->{'obj'}->{'event'}->register_event_callbacks();
		$self->{'obj'}->{'eventloop'}->event_loop();
	}

	CLEAN_UP_AND_RESTORE_DISPLAY_CONSOLE: {

		$self->{'obj'}->{'console'}->w32cons_cursor_tleft_dsp();
		$self->{'obj'}->{'console'}->w32cons_close();
	}

	return (1);
}

sub display_help_msg {

	print 
	  "--------------------------------------------------------------------------------- \n" . 
	  " Command Line Options                  EXAMPLE:   ./ZHex.pl -f file.txt -v 3      \n" . 
	  "--------------------------   -----   -------------------------------------------- \n" . 
	  "  Option Name   Long Form    Short   Description                         Req/Opt  \n" . 
	  "  -----------   ----------   -----   -----------                         -------- \n" . 
	  "  FILENAME      --filename   -f      Filename                            REQUIRED \n" . 
	  "  DEBUG INFO    --dbg        -v      Increase amount of info displayed   Optional \n" . 
	  "  HELP  TEXT    --help       -?      Display help text (this page)       Optional \n";
}


END { undef; }
1;


__END__


=head1 NAME

ZHex - Zebra Hex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use ZHex;

    my $editorObj = ZHex->new();
    ...

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS


=head2 init
Method init()...
= cut

=head2 init_config_main
Method init_config_main()...
= cut

=head2 init_cli_opts_main
Method init_cli_opts_main()...
= cut

=head2 init_objects_main
Method init_objects_main()...
= cut

=head2 run
Method run()...
= cut

=head2 display_help_msg
Method display_help_msg()...
= cut

=head2 set_accessors_main
Method set_accessors_main()...
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

