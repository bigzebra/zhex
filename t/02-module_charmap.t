#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\CharMap.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   chr_map()
#   chr_map_set()
#   init()
# Values exported: 
#   <NONE>

use_ok ('ZHex::CharMap') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::CharMap')";

my @objCharMapSubs = 
  ('chr_map', 
   'chr_map_set', 
   'init',
   'new', 
   'obj_init');

can_ok ('ZHex::CharMap', 'new');
my $objCharMap = ZHex::CharMap->new();
isa_ok ($objCharMap, 'ZHex::CharMap', 'CharMap');
can_ok ($objCharMap, @objCharMapSubs);

