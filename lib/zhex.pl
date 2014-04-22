#!/usr/bin/perl -w

# ______________________________________________________________________
# ZHex - ZHex Editor (v0.02) (4/14/2014) (by Double Z)
# ZHex Shell (zhexsh.pl)
# ______________________________________________________________________

package main;

use warnings;
use strict;

use ZHex;

my $zhex = ZHex->new();

$zhex->init_cli_opts_main();

$zhex->init_objects_main();

$zhex->init_console_obj();
$zhex->init_display_obj();

$zhex->init_cursor_obj();
$zhex->init_editor_obj();

$zhex->init_display_elements();

$zhex->init_file_obj();

$zhex->clear_console();

$zhex->write_editor_to_display();

$zhex->run();

exit (0);


__END__

