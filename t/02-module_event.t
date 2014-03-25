#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Event.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   debug_off()
#   debug_on()
#   init()
#   insert_backspace()
#   insert_char()
#   insert_enter()
#   insert_escape()
#   insert_l_arrow()
#   insert_mode()
#   insert_r_arrow()
#   move_to_beginning()
#   move_to_end()
#   quit()
#   register_event_callbacks()
#   search_backspace()
#   search_box()
#   search_char()
#   search_enter()
#   search_escape()
#   search_l_arrow()
#   search_mode()
#   search_r_arrow()
#   vstretch()
#   vcompress()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Event') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Event')";

my @objEventSubs = 
  ('debug_off', 
   'debug_on', 
   'init', 
   'insert_backspace', 
   'insert_char', 
   'insert_enter', 
   'insert_escape', 
   'insert_l_arrow', 
   'insert_mode', 
   'insert_r_arrow', 
   'move_to_beginning', 
   'move_to_end', 
   'new', 
   'obj_init', 
   'quit', 
   'register_event_callbacks', 
   'search_backspace', 
   'search_box', 
   'search_char', 
   'search_enter', 
   'search_escape', 
   'search_l_arrow', 
   'search_mode', 
   'search_r_arrow',
   'vstretch', 
   'vcompress');

can_ok ('ZHex::Event', 'new');
my $objEvent = ZHex::Event->new();
isa_ok ($objEvent, 'ZHex::Event', 'Event');
can_ok ($objEvent, @objEventSubs);

