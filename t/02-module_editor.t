#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Editor.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   gen_char()
#   gen_hdr()
#   gen_hex()
#   gen_lnum()
#   gen_ofs_dec()
#   gen_ofs_hex()
#   gen_sep()
#   init()
#   scroll_down_1x_line()
#   scroll_down_1x_page()
#   scroll_up_1x_line()
#   scroll_up_1x_page()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Editor') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Editor')";

my @objEditorSubs = 
  ('gen_char', 
   'gen_hdr', 
   'gen_hex', 
   'gen_lnum', 
   'gen_ofs_dec', 
   'gen_ofs_hex', 
   'gen_sep', 
   'init', 
   'new', 
   'obj_init', 
   'scroll_down_1x_line', 
   'scroll_down_1x_page', 
   'scroll_up_1x_line', 
   'scroll_up_1x_page');

can_ok ('ZHex::Editor', 'new');
my $objEditor = ZHex::Editor->new();
isa_ok ($objEditor, 'ZHex::Editor', 'Editor');
can_ok ($objEditor, @objEditorSubs);

