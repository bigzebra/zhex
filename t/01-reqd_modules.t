#!/usr/bin/perl

package main;

use warnings;
use strict;

use Test::More tests => 16;

# ______________________________________________________________________
# Test availablility of modules: 3rd party modules (used by unit tests/program/program modules).
#   1) Encode			Required by: ZHex\Editor.pm
#   2) Exporter			Required by: Every program module.
#   3) IO::File			Required by: Unit tests.
#   4) Test::More		ALREADY INCLUDED (ABOVE).
#   5) Time::HiRes		Required by: ZHex\EventLoop.pm
#   6) Win32::Console		Required by: ZHex\Console.pm

BEGIN {

	use_ok ('Exporter')       or die "Call to use_ok() returned w/ failure (on module 'Exporter')";
	use_ok ('Encode')         or die "Call to use_ok() returned w/ failure (on module 'Encode')";
	use_ok ('IO::File')       or die "Call to use_ok() returned w/ failure (on module 'IO::File')";
	use_ok ('Test::More')     or die "Call to use_ok() returned w/ failure (on module 'Test::More')";
	use_ok ('Time::HiRes')    or die "Call to use_ok() returned w/ failure (on module 'Time::HiRes')";
	use_ok ('Win32::Console') or die "Call to use_ok() returned w/ failure (on module 'Win32::Console')";
}

# ______________________________________________________________________
# Test availablility of modules: program modules (used by program/program modules).
#    1) ZHex\Common.pm	        ZHex::Common
#    2) ZHex\CharMap.pm		ZHex::CharMap
#    3) ZHex\Console.pm		ZHex::Console
#    4) ZHex\Cursor.pm		ZHex::Cursor
#    5) ZHex\Debug.pm		ZHex::Debug
#    6) ZHex\Display.pm		ZHex::Display
#    7) ZHex\Editor.pm		ZHex::Editor
#    8) ZHex\Event.pm		ZHex::Event
#    9) ZHex\EventLoop.pm	ZHex::EventLoop
#   10) ZHex\File.pm		ZHex::File

BEGIN {

	use_ok ('ZHex::Common') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Common')";

	use_ok ('ZHex::CharMap') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::CharMap')";

	use_ok ('ZHex::Console') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Console')";

	use_ok ('ZHex::Cursor') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Cursor')";

	use_ok ('ZHex::Debug') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Debug')";

	use_ok ('ZHex::Display') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Display')";

	use_ok ('ZHex::Editor') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Editor')";

	use_ok ('ZHex::Event') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::Event')";

	use_ok ('ZHex::EventLoop') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::EventLoop')";

	use_ok ('ZHex::File') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::File')";
}

