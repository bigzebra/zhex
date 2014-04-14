#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Mouse.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::Common.pm.
#   init()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   lmouse()
#   mouse_over()
#   rmouse()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Mouse') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Mouse')";

my @objMouseSubs = 
  ('init', 
   'new', 
   'obj_init', 
   'lmouse', 
   'mouse_over', 
   'rmouse');

can_ok ('ZHex::Mouse', 'new');
my $objMouse = ZHex::Mouse->new();
isa_ok ($objMouse, 'ZHex::Mouse', 'Mouse');
can_ok ($objMouse, @objMouseSubs);

