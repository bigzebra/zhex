#!/usr/bin/perl

# ______________________________________________________________________________
# ExtUtils::Manifest test program.                      by Double Z  Mar 24 2014
# ______________________________________________________________________________

use warnings;
use strict;

use ExtUtils::Manifest 
  qw(mkmanifest 
     manicheck 
     skipcheck 
     filecheck 
     fullcheck 
     manifind 
     maniread 
     manicopy 
     maniadd);

# ______________________________________________________________________________
# mkmanifest()
#   Writes all files in and below the current directory to your
#   MANIFEST. It works similar to the result of the Unix command
#   All files that match any regular expression in a file MANIFEST.SKIP
#   (if it exists) are ignored.

mkmanifest();


# ______________________________________________________________________________
# manicheck()
#   Checks if all the files within a "MANIFEST" in the current directory
#   really do exist. If "MANIFEST" and the tree below the current
#   directory are in sync it silently returns an empty list. Otherwise
#   it returns a list of files which are listed in the "MANIFEST" but
#   missing from the directory, and by default also outputs these names
#   to STDERR.


my @missing_files = manicheck();

# ______________________________________________________________________________
# skipcheck()
#   Lists all the files that are skipped due to your "MANIFEST.SKIP"
#   file.

my @skipped = skipcheck();


# ______________________________________________________________________________
# filecheck()
#   Finds files below the current directory that are not mentioned in
#   the "MANIFEST" file. An optional file "MANIFEST.SKIP" will be
#   consulted. Any file matching a regular expression in such a file
#   will not be reported as missing in the "MANIFEST" file. The list of
#   any extraneous files found is returned, and by default also reported
#   to STDERR.

my @extra_files = filecheck();


# ______________________________________________________________________________
# fullcheck()
#   Does both a manicheck() and a filecheck(), returning then as two
#   array refs.

my ($missing, $extra) = fullcheck();


# ______________________________________________________________________________
# manifind()
#   Returns a hash reference. The keys of the hash are the files found
#   below the current directory.

my $found = manifind();


# ______________________________________________________________________________
# maniread()
#   Reads a named "MANIFEST" file (defaults to "MANIFEST" in the current
#   directory) and returns a HASH reference with files being the keys
#   and comments being the values of the HASH. Blank lines and lines
#   which start with "#" in the "MANIFEST" file are discarded.

my $manifest = maniread();


# ______________________________________________________________________________
# maniadd()
#   Adds an entry to an existing MANIFEST unless its already there.
#   $file will be normalized (ie. Unixified). UNIMPLEMENTED

# maniadd ({$file => $comment, ...});


exit (0);


__END__

