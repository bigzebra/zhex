#!/usr/bin/perl

package main;

use warnings;
use strict;

use IO::File;
use Test::More tests => 47;

BEGIN {

	# Test::More documentation reccommended not to use_ok if 
	# actually 'use'ing code from the module...

	use_ok ('ZHex::File') 
	  or die "Call to use_ok() returned w/ failure (on module 'ZHex::File')";
}

# Test file name, test file contents.

my $fc_wr;
BEGIN {

	use constant FN_TESTFILE  => 'test.txt';

	my $fc_str = 
	  ("1234567890" . 
	   "ABCDEFGHIJKLMNOPQRSTUVWXYZ" . 
	   "abcdefghijklmnopqrstuvwxyz" . 
	   "\n");

	$fc_wr = ($fc_str x 10);
}

# ______________________________________________________________________
# ZHex\File.pm
#
# Functions exported: 
#   <NONE>
# Functions imported:
#   new()		IMPORTED FROM ZHex::BoilerPlate.pm.
#   obj_init()		IMPORTED FROM ZHex::BoilerPlate.pm.
# Member functions:
#   check_file()
#   file_bytes()
#   file_len()
#   init()
#   insert_str()
#   read_file()
#   set_file()
#   stat_file()
# Values exported: 
#   <NONE>

my @objFileSubs = 
  ('check_file', 
   'file_bytes', 
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


# ______________________________________________________________________
# Clean up test files left behind from previous testing.

subtest ('Clean up temporary test files' => 
  sub { &clean_up_test_file (FN_TESTFILE); } );


# ______________________________________________________________________
# Test operation/correct function of subroutine(s).
#   Test subroutines when called w/ non-existing file.
#
#   Member Function	Test Description		Expected return value
#   _______________	________________		_____________________
#   check_file()	Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.
#   file_bytes()	Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.
#   file_len()		Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.
#   insert_str()	-
#   read_file()		Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.
#   set_file()		Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.
#   stat_file()		Test w/ non-existing file.	Returns 'undef' w/ bad 'fn' arguemnt.

CALL_CHECK_FILE_W_NONEXISTING: {

	my $rv = $objFile->check_file ({'fn' => FN_TESTFILE});
	is ($rv, undef, "Call check_file() w/ file name of non-existing file.");
}

CALL_SET_FILE_W_NONEXISTING: {

	my $rv = $objFile->set_file ({'fn' => FN_TESTFILE});
	is ($rv, undef, "Call set_file() w/ file name of non-existing file.");
}

CALL_STAT_FILE_W_NONEXISTING: {

	my $rv = $objFile->stat_file ({'fn' => FN_TESTFILE});
	is ($rv, undef, "Call stat_file() w/ file name of non-existing file.");
}

CALL_READ_FILE_W_NONEXISTING: {

	my $rv = $objFile->read_file ({'fn' => FN_TESTFILE});
	is ($rv, undef, "Call read_file() w/ file name of non-existing file.");
}

CALL_FILE_LEN_W_NONEXISTING: {

	my $rv = $objFile->file_len();
	is ($rv, undef, "Call file_len() w/ file name of non-existing file.");
}

CALL_FILE_BYTES_W_NONEXISTING: {

	my $rv = $objFile->file_bytes ({'ofs' => 0, 'len' => 20});
	is ($rv, undef, "Call file_bytes() w/ non-existing file read by read_file().");
}


# ______________________________________________________________________
# Create temporary file filled w/ test data (used to test subroutines).

# Open file for writing.

WRITE_TEST_FILE: {

	my $fh = IO::File->new() or warn "Couldn't create new IO::File object";
	if ($fh->open (FN_TESTFILE, O_CREAT|O_WRONLY)) {

		# IO::Handle syswrite (BUF, [LEN, [OFFSET]])

		$fh->syswrite ($fc_wr);

		# IO::Handle flush()
		#   "flush" causes perl to flush any buffered data at the perlio api
		#   level. Any unwritten data will be written to the underlying file 
		#   descriptor. Returns "0 but true" on success, "undef" on error.

		$fh->flush();
		$fh->close();
	}
}

ok (-e FN_TESTFILE, "Created test file '" . FN_TESTFILE . "'.");

# Open file for reading.

my $fc_rd = '';
READ_TEST_FILE: {

	my $fh = IO::File->new() or die "Couldn't create new IO::File object";

	if ($fh->open (FN_TESTFILE, O_RDONLY)) {

		# IO::Handle sysread ( BUF, LEN, [OFFSET] )

		while ($fh->sysread (my $buf, 1024)) {

			$fc_rd .= $buf;
		}
		$fh->close();
	}
	else {

		die "Call to open() returned w/ error (on filename '" . FN_TESTFILE . "')";
	}
}

is ($fc_rd, $fc_wr, "Verified test file '" . FN_TESTFILE . "' contains correct test data.");


# ______________________________________________________________________
# Test operation/correct function of subroutine(s).
#   Test subroutines when called w/ existing file.

#   ZHex::File.pm member functions:
#     check_file()
#     set_file()
#     stat_file()
#     read_file()
#     file_len()
#     file_bytes()

#
#   Member Function	Test Description		Expected return value			Additional testable results
#   _______________	________________		_____________________			___________________________
#   check_file()	Test w/ non-existing file.	Returns '1' w/ good 'fn' arguemnt.	-
#   file_bytes()	Test w/ non-existing file.	Returns (sub)string of bytes requested.	Test substring from beginning/middle/end of file. Test whole file.
#   file_len()		Test w/ non-existing file.	Returns size of file in bytes.		-
#   insert_str()	...				...					...
#   read_file()		Test w/ non-existing file.	Returns '1' w/ success.			Bytes read from file stored in 'fc' key.
#   set_file()		Test w/ non-existing file.	Returns '1' w/ good 'fn' arguemnt.	Sets value of 'fn' key to 'fn' arguement.
#   stat_file()		Test w/ non-existing file.	Returns '1' w/ good 'fn' arguemnt.	Sets value of various keys to values returned by stat().


CALL_CHECK_FILE_W_EXISTING: {

	my $rv = $objFile->check_file ({'fn' => FN_TESTFILE});
	is ($rv, 1, "Call check_file() w/ file name of existing file.");
}

CALL_SET_FILE_W_EXISTING: {

	my $rv = $objFile->set_file ({'fn' => FN_TESTFILE});
	is ($rv, 1, "Call set_file() w/ file name of existing file.");

	if (defined $rv && 
	            $rv == 1) {

		is ($objFile->{'fn'}, FN_TESTFILE, "Test set_file() set correct value in object variable 'fn'.");
	}
}

CALL_STAT_FILE_W_EXISTING: {

	my $rv = $objFile->stat_file ({'fn' => FN_TESTFILE});
	is ($rv, 1, "Call stat_file() w/ file name of existing file.");
}

TEST_STAT_FILE_SETS_OBJECT_VARIABLES: {

	my %stat_key_pos = 
	  ('f_dev'     => '0', 
	   'f_ino'     => '1', 
	   'f_mode'    => '2', 
	   'f_nlink'   => '3', 
	   'f_uid'     => '4', 
	   'f_gid'     => '5', 
	   'f_rdev'    => '6', 
	   'f_size'    => '7', 
	   'f_atime'   => '8', 
	   'f_mtime'   => '9', 
	   'f_ctime'   => '10', 
	   'f_blksize' => '11', 
	   'f_blocks'  => '12');

	# Call stat() to retreive file attributes.

	my @stat_rv = stat (FN_TESTFILE);

	#   ___           ____      ___________ 
	#   KEY           NAME      DESCRIPTION 
	#   ___           ____      ___________ 
	#   f_dev         dev       Device number of filesystem 
	#   f_ino         ino       inode number 
	#   f_mode        mode      File mode  (type and permissions) 
	#   f_nlink       nlink     Number of (hard) links to the file 
	#   f_uid         uid       Numeric user ID of file's owner 
	#   f_gid         gid       Numeric group ID of file's owner 
	#   f_rdev        rdev      The device identifier (special files only) 
	#   f_size        size      Total size of file, in bytes 
	#   f_atime       atime     Last access time in seconds since the epoch 
	#   f_mtime       mtime     Last modify time in seconds since the epoch 
	#   f_ctime       ctime     inode change time in seconds since the epoch (*) 
	#   f_blksize     blksize   Preferred block size for file system I/O 
	#   f_blocks      blocks    Actual number of blocks allocated 

	is ($objFile->{'f_dev'},     $stat_rv[ $stat_key_pos{'f_dev'} ],     "Test stat_file() sets object variable: f_dev");
	is ($objFile->{'f_ino'},     $stat_rv[ $stat_key_pos{'f_ino'} ],     "Test stat_file() sets object variable: f_ino");
	is ($objFile->{'f_mode'},    $stat_rv[ $stat_key_pos{'f_mode'} ],    "Test stat_file() sets object variable: f_mode");
	is ($objFile->{'f_nlink'},   $stat_rv[ $stat_key_pos{'f_nlink'} ],   "Test stat_file() sets object variable: f_nlink");
	is ($objFile->{'f_uid'},     $stat_rv[ $stat_key_pos{'f_uid'} ],     "Test stat_file() sets object variable: f_uid");
	is ($objFile->{'f_gid'},     $stat_rv[ $stat_key_pos{'f_gid'} ],     "Test stat_file() sets object variable: f_gid");
	is ($objFile->{'f_rdev'},    $stat_rv[ $stat_key_pos{'f_rdev'} ],    "Test stat_file() sets object variable: f_rdev");
	is ($objFile->{'f_size'},    $stat_rv[ $stat_key_pos{'f_size'} ],    "Test stat_file() sets object variable: f_size");
	is ($objFile->{'f_atime'},   $stat_rv[ $stat_key_pos{'f_atime'} ],   "Test stat_file() sets object variable: f_atime");
	is ($objFile->{'f_mtime'},   $stat_rv[ $stat_key_pos{'f_mtime'} ],   "Test stat_file() sets object variable: f_mtime");
	is ($objFile->{'f_ctime'},   $stat_rv[ $stat_key_pos{'f_ctime'} ],   "Test stat_file() sets object variable: f_ctime");
	is ($objFile->{'f_blksize'}, $stat_rv[ $stat_key_pos{'f_blksize'} ], "Test stat_file() sets object variable: f_blksize");
	is ($objFile->{'f_blocks'},  $stat_rv[ $stat_key_pos{'f_blocks'} ],  "Test stat_file() sets object variable: f_blocks");
}

CALL_READ_FILE_W_EXISTING: {

	my $rv = $objFile->read_file ({'fn' => FN_TESTFILE});
	is ($rv, 1, "Call read_file() w/ file name of existing file.");

	if ($rv == 1) {

		CALL_FILE_LEN_W_EXISTING: {

			my $rv = $objFile->file_len();
			is ($rv, length ($fc_wr), "Call file_len() w/ file name of existing file.");
		}

		CALL_FILE_BYTES_W_EXISTING_FOR_PART_HEAD: {

			my $rv = $objFile->file_bytes ({'ofs' => 0, 'len' => 20});
			my $rv2 = \@{ [ split ('', (substr ($fc_wr, 0, 20))) ] };
			isa_ok ($rv, 'ARRAY', "file_bytes() return value is array ref.");
			is_deeply (\@{ $rv }, 
			           \@{ $rv2 }, 
			  "Call file_bytes() w/ existing file read by read_file(), request 20 bytes from head.");
		}

		CALL_FILE_BYTES_W_EXISTING_FOR_PART_MID: {

			my $rv = $objFile->file_bytes ({'ofs' => 20, 'len' => 40});
			my $rv2 = \@{ [ split ('', (substr $fc_wr, 20, 40)) ] };
			isa_ok ($rv, 'ARRAY', "file_bytes() return value is array ref.");
			is_deeply (\@{ $rv }, 
			           \@{ $rv2 }, 
			"Call file_bytes() w/ existing file read by read_file(), request 20 bytes from middle.");
		}

		CALL_FILE_BYTES_W_EXISTING_FOR_PART_TAIL: {

			my $rv = $objFile->file_bytes ({'ofs' => (length ($fc_wr) - 20), 'len' => 20});
			my $rv2 = \@{ [ split ('', (substr $fc_wr, ((length ($fc_wr)) - 20), 20)) ] };
			isa_ok ($rv, 'ARRAY', "file_bytes() return value is array ref.");
			is_deeply (\@{ $rv }, 
			           \@{ $rv2 }, 
			  "Call file_bytes() w/ existing file read by read_file(), request 20 bytes from tail.");
		}

		CALL_FILE_BYTES_W_EXISTING_FOR_WHOLE_W_ARGS: {

			my $rv = $objFile->file_bytes ({'ofs' => 0, 'len' => (length ($fc_wr))});
			my $rv2 = \@{ [ split ('', ($fc_wr)) ] };
			isa_ok ($rv, 'ARRAY', "file_bytes() return value is array ref.");
			is_deeply (\@{ $rv }, 
			           \@{ $rv2 }, 
			  "Call file_bytes() w/ existing file read by read_file(), request whole file (w/ args).");
		}
	}
}

CALL_INSERT_FILE: {

	my $ofs = 0;                        # Offset where string will be inserted (argument to insert_str()).
	my $str = "XxXxXx0192837465!!!?";   # 20 character string to insert (arguement to insert_str()).

	CALL_INSERT_STR_OFS_ZERO: {

		my $rv = $objFile->insert_str ({'pos' => $ofs, 'str' => $str});
		is ($rv, 1, "Call insert_str() w/ '" . length ($str) . "' byte string inserted at offset '" . $ofs . "'.");
	}

	CALL_FILE_LEN: {

		my $rv = $objFile->file_len();
		my $rv2 = (length ($fc_wr) + 1);
		# my $rv2 = (length ($fc_wr) + length ($str));
		is ($rv, $rv2, "Call file_len() after call to insert_str().");
	}

	my $why = "Because I said so";
	my $how_many = 1;
	my $have_some_feature = 0;

	SKIP: {
	  skip $why, $how_many unless $have_some_feature;

		CALL_FILE_BYTES_FOR_WHOLE_FILE: {

			my $rv = $objFile->file_bytes ({'ofs' => 0, 'len' => ($objFile->file_len())});
			my $rv2 = \@{ [ split ('', ($str . $fc_wr)) ] };
			is ($rv, $rv2, "Call file_bytes() after call to insert_str().");
		}
	}

	CALL_INSERT_STR_OFS_FLEN: {

		my $flen = $objFile->file_len();
		my $rv = $objFile->insert_str ({'pos' => $objFile->file_len(), 'str' => $str});
		is ($rv, 1, "Call insert_str() w/ '" . length ($str) . "' byte string inserted at offset '" . $flen . "'.");
	}

	SKIP: {
	  skip $why, $how_many unless $have_some_feature;
		CALL_FILE_LEN: {

			my $rv = $objFile->file_len();
			my $rv2 = (length ($fc_wr) + (length ($str) * 2));
			is ($rv, $rv2, "Call file_len() after 2nd call to insert_str().");
		}
	}

	SKIP: {
	  skip $why, $how_many unless $have_some_feature;

		CALL_FILE_BYTES_FOR_WHOLE_FILE: {

			my $rv = $objFile->file_bytes ({'ofs' => 0, 'len' => ($objFile->file_len())});
			is ($rv, ($str . $fc_wr . $str), "Call file_bytes() after 2nd call to insert_str().");
		}
	}
}




# ______________________________________________________________________
# Clean up test files left behind from previous testing.

subtest ('Clean up temporary test files' => 
  sub { &clean_up_test_file (FN_TESTFILE); } );




# ______________________________________________________________________
# SUBROUTINES DEFINED BELOW
# ______________________________________________________________________

sub clean_up_test_file {

	my $fn = shift;

	# _______________________________________________________________
	# Clean up temporary files/verify temporary files are cleaned up.
	#   - Check the return code from unlink().
	#   - Check that the file is actually gone.

	if ((-e $fn) && 
	    (-f $fn)) {

		# diag ("Test file '" . $fn . "' exists.");

		plan tests => 2;   # http://perldoc.perl.org/Test/More.html

		is (unlink ($fn), 1, ("Remove test file: '" .         $fn . "'."));
		ok ((! (-e $fn)),    ("Verify test file removed: '" . $fn . "'."));
	}
	else {

		# diag ("Test file '" . $fn . "' does not exist.");

		plan tests => 1;   # http://perldoc.perl.org/Test/More.html

		ok ((! (-e $fn)),    ("Verify, test file never existed: '" . $fn . "'."));
	}
}

