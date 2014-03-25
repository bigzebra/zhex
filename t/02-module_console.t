#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Console.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   colorize_combine_attrs()
#   colorize_display()
#   colorize_reverse()
#   init()
#   lmouse()
#   mouse_over()
#   rmouse()
#   w32cons_clear()
#   w32cons_close()
#   w32cons_cursor_bleft_dsp()
#   w32cons_cursor_invisible()
#   w32cons_cursor_move()
#   w32cons_cursor_tleft_dsp()
#   w32cons_cursor_visible()
#   w32cons_fg_white_bg_black()
#   w32cons_init()
#   w32cons_mode_set()
#   w32cons_refresh_display()
#   w32cons_size_set()
#   w32cons_termcap()
#   w32cons_title_get()
#   w32cons_title_set()
#   w32cons_write()
# Values exported: 
#   <NONE>

use_ok ('ZHex::Console') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Console')";

my @objConsoleSubs = 
  ('colorize_combine_attrs', 
   'colorize_display', 
   'colorize_reverse', 
   'init', 
   'lmouse', 
   'mouse_over', 
   'new', 
   'obj_init', 
   'rmouse', 
   'w32cons_clear', 
   'w32cons_close', 
   'w32cons_cursor_bleft_dsp', 
   'w32cons_cursor_invisible', 
   'w32cons_cursor_move', 
   'w32cons_cursor_tleft_dsp', 
   'w32cons_cursor_visible', 
   'w32cons_fg_white_bg_black', 
   'w32cons_init', 
   'w32cons_mode_set', 
   'w32cons_refresh_display', 
   'w32cons_size_set', 
   'w32cons_termcap', 
   'w32cons_title_get', 
   'w32cons_title_set', 
   'w32cons_write');

can_ok ('ZHex::Console', 'new');
my $objConsole = ZHex::Console->new();
isa_ok ($objConsole, 'ZHex::Console', 'Console');
can_ok ($objConsole, @objConsoleSubs);

