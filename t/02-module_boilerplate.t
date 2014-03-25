#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\BoilerPlate.pm
#
# Functions exported:
#   init()
#   new()
#   obj_init()
# Functions imported:
#   <NONE>
# Member functions: 
#   init()		SAME AS ABOVE (EXPORTED).
#   new()		SAME AS ABOVE (EXPORTED).
#   obj_init()		SAME AS ABOVE (EXPORTED).
# Values exported: 
#   <NONE>

use_ok ('ZHex::BoilerPlate') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::BoilerPlate')";

my @objBoilerPlateSubs = 
  ('init', 
   'new', 
   'obj_init');

can_ok ('ZHex::BoilerPlate', 'new');
my $objBoilerPlate = ZHex::BoilerPlate->new();
isa_ok ($objBoilerPlate, 'ZHex::BoilerPlate', 'BoilerPlate');
can_ok ($objBoilerPlate, @objBoilerPlateSubs);

