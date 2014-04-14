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
#   register_callback()		Register callback subroutine to handle event under certain context.
#   register_evt_sig()		Register event signature (unique values of evt array that identify different keystrokes).
#   gen_evt_array()		...
#   evt_map()			...
#   evt_dispatch()		...
# Values exported: 
#   <NONE>

use_ok ('ZHex::Event') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Event')";

my @objEventSubs = 
  ('init', 
   'new', 
   'obj_init', 
   'register_callback', 
   'register_evt_sig', 
   'gen_evt_array', 
   'evt_map', 
   'evt_dispatch');

can_ok ('ZHex::Event', 'new');
my $objEvent = ZHex::Event->new();
isa_ok ($objEvent, 'ZHex::Event', 'Event');
can_ok ($objEvent, @objEventSubs);

