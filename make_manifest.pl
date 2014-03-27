#!/usr/bin/perl

# ______________________________________________________________________________
# ExtUtils::Manifest test program.                      by Double Z  Mar 24 2014
# ______________________________________________________________________________

use warnings;
use strict;

use ExtUtils::Manifest qw(mkmanifest);

# mkmanifest()
#
#   Writes all files in and below the current directory to your
#   MANIFEST. It works similar to the result of the Unix command
#   All files that match any regular expression in a file MANIFEST.SKIP
#   (if it exists) are ignored.

mkmanifest();

exit (0);


__END__

