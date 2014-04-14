#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\EventHandler.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::Common.pm.
#   inti()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   ...
# Values exported: 
#   <NONE>

use_ok ('ZHex::EventHandler') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::EventHandler')";

my @objEventHandlerSubs = 
  ('new', 
   'init', 
   'obj_init', 
   'register_evt_callbacks', 
   'quit', 
   'curs_move_beg', 
   'curs_move_end', 
   'curs_ctxt_incr', 
   'curs_ctxt_decr', 
   'curs_mv_back', 
   'curs_mv_fwd', 
   'curs_mv_up', 
   'curs_mv_down', 
   'curs_mv_left', 
   'curs_mv_right', 
   'debug_off', 
   'debug_on', 
   'vstretch', 
   'vcompress', 
   'scroll_up_1x_line', 
   'scroll_up_1x_page', 
   'scroll_down_1x_line', 
   'scroll_down_1x_page', 
   'insert_mode', 
   'search_mode', 
   'write_file', 
   'lmouse', 
   'rmouse', 
   'search_backspace', 
   'search_char', 
   'search_enter', 
   'search_escape', 
   'search_l_arrow', 
   'search_r_arrow', 
   'insert_backspace', 
   'insert_char', 
   'insert_enter', 
   'insert_escape', 
   'insert_l_arrow', 
   'insert_r_arrow', 
   'search_box');

can_ok ('ZHex::EventHandler', 'new');
my $objEventHandler = ZHex::EventHandler->new();
isa_ok ($objEventHandler, 'ZHex::EventHandler', 'EventHandler');
can_ok ($objEventHandler, @objEventHandlerSubs);

