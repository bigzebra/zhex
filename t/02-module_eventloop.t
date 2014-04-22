#!/usr/bin/perl

package main;

use warnings;
use strict;
$| = 1;

use Test::More tests => 4;

# ______________________________________________________________________
# ZHex\EventLoop.pm

use_ok ('ZHex::EventLoop') 
  or die "Call to use_ok() returned w/ failure (on module 'ZHex::EventLoop')";

my @objEventLoopSubs = 
  ('init', 
   'new', 
   'obj_init', 
   'evt_read', 
   'evt_keyboard_filter', 
   'evt_mouse_filter', 
   'evt_loop');

can_ok ('ZHex::EventLoop', 'new');
my $objEventLoop = ZHex::EventLoop->new();
isa_ok ($objEventLoop, 'ZHex::EventLoop', 'EventLoop');
can_ok ($objEventLoop, @objEventLoopSubs);

