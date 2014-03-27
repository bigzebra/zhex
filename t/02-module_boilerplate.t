#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Common.pm
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

use_ok ('ZHex::Common') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Common')";

my @objCommonSubs = 
  ('init', 
   'new', 
   'obj_init');

can_ok ('ZHex::Common', 'new');
my $objCommon = ZHex::Common->new();
isa_ok ($objCommon, 'ZHex::Common', 'Common');
can_ok ($objCommon, @objCommonSubs);

