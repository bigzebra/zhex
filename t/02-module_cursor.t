#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\Cursor.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::Common.pm.
#   obj_init()		IMPORTED FROM ZHex::Common.pm.
# Member functions:
#   align_line_boundary()
#   align_word_boundary()
#   calc_coord_array()
#   calc_row()
#   calc_row_offset()
#   comp_coord_arrays()
#   curs_ctxt_decr()
#   curs_ctxt_incr()
#   curs_display()
#   curs_mv_back()
#   curs_mv_down()
#   curs_mv_fwd()
#   curs_mv_left()
#   curs_mv_right()
#   curs_mv_up()
#   dsp_coord()
#   init()
# Values exported: 
#   CURS_CTXT_LINE 
#   CURS_CTXT_WORD 
#   CURS_CTXT_BYTE 
#   CURS_CTXT_INSR

use_ok ('ZHex::Cursor') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Cursor')";

my @objCursorSubs = 
  ('align_line_boundary', 
   'align_word_boundary', 
   'calc_coord_array', 
   'calc_row', 
   'calc_row_offset', 
   'comp_coord_arrays', 
   'curs_ctxt_decr', 
   'curs_ctxt_incr', 
   'curs_display', 
   'curs_mv_back', 
   'curs_mv_down', 
   'curs_mv_fwd', 
   'curs_mv_left', 
   'curs_mv_right', 
   'curs_mv_up', 
   'dsp_coord', 
   'init',
   'new', 
   'obj_init');

can_ok ('ZHex::Cursor', 'new');
my $objCursor = ZHex::Cursor->new();
isa_ok ($objCursor, 'ZHex::Cursor', 'Cursor');
can_ok ($objCursor, @objCursorSubs);

