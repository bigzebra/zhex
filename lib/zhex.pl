#!/usr/bin/perl

# ______________________________________________________________________
# ZHex - ZebraHex Editor (v0.02) (4/6/2014) (by Double Z)
# ZHex Shell (zhexsh.pl)
# ______________________________________________________________________

package main;

use warnings;
use strict;

use ZHex;

my $zhex = ZHex->new();

$zhex->init_cli_opts_main();
$zhex->init_objects_main();
$zhex->set_accessors_main();

$zhex->run();

exit (0);


__END__

