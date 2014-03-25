#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\EventLoop.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   event_loop()
#   init()
#   read_evt()
#   register_callback()
# Values exported: 
#   <NONE>

use_ok ('ZHex::EventLoop') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::EventLoop')";

my @objEventLoopSubs = 
  ('event_loop', 
   'init', 
   'new', 
   'obj_init', 
   'read_evt', 
   'register_callback');

can_ok ('ZHex::EventLoop', 'new');
my $objEventLoop = ZHex::EventLoop->new();
isa_ok ($objEventLoop, 'ZHex::EventLoop', 'EventLoop');
can_ok ($objEventLoop, @objEventLoopSubs);

