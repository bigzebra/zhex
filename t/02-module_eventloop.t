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
#   new()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   init()
#   evt_read()
#   evt_filter()
#   evt_mouse()
#   evt_loop()

# Values exported: 
#   <NONE>

use_ok ('ZHex::EventLoop') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::EventLoop')";

my @objEventLoopSubs = 
  ('init', 
   'new', 
   'obj_init', 
   'evt_read', 
   'evt_filter', 
   'evt_mouse', 
   'evt_loop');

can_ok ('ZHex::EventLoop', 'new');
my $objEventLoop = ZHex::EventLoop->new();
isa_ok ($objEventLoop, 'ZHex::EventLoop', 'EventLoop');
can_ok ($objEventLoop, @objEventLoopSubs);

