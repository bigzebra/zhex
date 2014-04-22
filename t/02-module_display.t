#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Display.pm

use_ok ('ZHex::Display') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Display')";

my @objDisplaySubs = 
  ('active_c_elements', 
   'active_d_elements', 
   'c_elements_init', 
   'c_elements_set', 
   'd_elements_init', 
   'd_elements_set', 
   'd_elements_tbl', 
   'dimension_x_set', 
   'dimension_y_set', 
   'dsp_prev_set', 
   'dsp_set', 
   'generate_blank_display', 
   'generate_blank_e_contents', 
   'generate_editor_display', 
   'init', 
   'new', 
   'obj_init', 
   'padding_left_set', 
   'padding_top_set');

can_ok ('ZHex::Display', 'new');
my $objDisplay = ZHex::Display->new();
isa_ok ($objDisplay, 'ZHex::Display', 'Display');
can_ok ($objDisplay, @objDisplaySubs);

