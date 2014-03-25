#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Debug.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   init()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   dbg_box()
#   dbg_console()
#   dbg_count()
#   dbg_curs()
#   dbg_display()
#   dbg_keybd_evt()
#   dbg_mouse_evt()
#   dbg_unmatched_evt()
#   errmsg()
#   errmsg_handler()
#   errmsg_queue()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Debug') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Debug')";

my @objDebugSubs = 
  ('dbg_box', 
   'dbg_console', 
   'dbg_count', 
   'dbg_curs', 
   'dbg_display', 
   'dbg_keybd_evt', 
   'dbg_mouse_evt', 
   'dbg_unmatched_evt', 
   'errmsg', 
   'errmsg_handler', 
   'errmsg_queue', 
   'init', 
   'new', 
   'obj_init');

can_ok ('ZHex::Debug', 'new');
my $objDebug = ZHex::Debug->new();
isa_ok ($objDebug, 'ZHex::Debug', 'Debug');
can_ok ($objDebug, @objDebugSubs);

