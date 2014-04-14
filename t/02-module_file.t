#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\File.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   file_bytes()
#   file_len()
#   init()
#   insert_str()
#   read_file()
#   set_file()
#   stat_file()
# Values exported: 
#   <NONE>

use_ok ('ZHex::File') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::File')";

my @objFileSubs = 
  ('file_bytes', 
   'file_len', 
   'init', 
   'insert_str', 
   'new', 
   'obj_init', 
   'read_file', 
   'set_file', 
   'stat_file');

can_ok ('ZHex::File', 'new');
my $objFile = ZHex::File->new();
isa_ok ($objFile, 'ZHex::File', 'File');
can_ok ($objFile, @objFileSubs);

