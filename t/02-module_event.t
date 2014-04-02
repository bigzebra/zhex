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
#   new()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   init()
#   insert_backspace()
#   insert_char()
#   insert_enter()
#   insert_escape()
#   insert_l_arrow()
#   insert_r_arrow()
#   quit()
#   register_evt_callbacks()
#   search_backspace()
#   search_box()
#   search_char()
#   search_enter()
#   search_escape()
#   search_l_arrow()
#   search_r_arrow()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Event') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Event')";

my @objEventSubs = 
  ('init', 
   'insert_backspace', 
   'insert_char', 
   'insert_enter', 
   'insert_escape', 
   'insert_l_arrow', 
   'insert_r_arrow', 
   'new', 
   'obj_init', 
   'quit', 
   'register_evt_callbacks', 
   'search_backspace', 
   'search_box', 
   'search_char', 
   'search_enter', 
   'search_escape', 
   'search_l_arrow', 
   'search_r_arrow');

can_ok ('ZHex::Event', 'new');
my $objEvent = ZHex::Event->new();
isa_ok ($objEvent, 'ZHex::Event', 'Event');
can_ok ($objEvent, @objEventSubs);

