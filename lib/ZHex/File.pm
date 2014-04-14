#!/usr/bin/perl

package ZHex::File;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     obj_init 
     $VERS 
     EDT_CTXT_DEFAULT 
     EDT_CTXT_INSERT 
     EDT_CTXT_SEARCH 
     SZ_READ);

use IO::File;
use Fcntl qw(:DEFAULT :Fcompat);

BEGIN { require Exporter;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(); 
}

# Functions: Start-Up/Initialization.
#
#   _____________		___________
#   Function Name		Description
#   _____________		___________
#   init()			Global variable declarations.
#   register_evt_callbacks()	Register event handler callbacks w/ event loop.

sub init {

	my $self = shift;

	# File attributes returned by function stat().

	$self->{'f_dev'}     = '';   # Return value f/ stat() function (13 values returned)
	$self->{'f_ino'}     = '';   # Return value f/ stat() function
	$self->{'f_mode'}    = '';   # Return value f/ stat() function
	$self->{'f_nlink'}   = '';   # Return value f/ stat() function
	$self->{'f_uid'}     = '';   # Return value f/ stat() function
	$self->{'f_gid'}     = '';   # Return value f/ stat() function
	$self->{'f_rdev'}    = '';   # Return value f/ stat() function
	$self->{'f_size'}    = '';   # Return value f/ stat() function
	$self->{'f_atime'}   = '';   # Return value f/ stat() function (date/time: last accessed)
	$self->{'f_mtime'}   = '';   # Return value f/ stat() function (date/time: last modified)
	$self->{'f_ctime'}   = '';   # Return value f/ stat() function (date/time: creation)
	$self->{'f_blksize'} = '';   # Return value f/ stat() function
	$self->{'f_blocks'}  = '';   # Return value f/ stat() function

	# Variables defined/used by function ...

	$self->{'fn'} = '';   # File name.
	$self->{'fc'} = [];   # File contents: reference to array of strings (binmode raw).

	return (1);
}

# Functions: File IO.
#
#   Function Name	Description
#   _____________	___________
#   set_file()		Store filename in self.
#   stat_file()		Wrapper for system stat() function.
#   read_file()		Method for reading file, store in object (system memory).
#   file_len()		Return number of bytes in file.
#   file_bytes()	Return list of bytes from 'pos' -> 'ofs'.
#   insert_str()	Insert byte at 'pos'.
#   write_file()	Write file to disk.

sub set_file {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to set_file() failed, argument must be hash reference"; }

	if (! exists  $arg->{'fn'} || 
	    ! defined $arg->{'fn'} || 
	             ($arg->{'fn'} eq '')) 
		{ die "Call to set_file() failed, value associated w/ key 'fn' was undef/empty string"; }

	# Test filename argument: verify that file exists on filesystem.

	if (! -e $arg->{'fn'} || 
	    ! -f $arg->{'fn'}) {

		return (undef);
	}

	$self->{'fn'} = $arg->{'fn'};

	return (1);
}

sub stat_file {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to stat_file() failed, argument must be hash reference"; }

	if (! exists  $arg->{'fn'} || 
	    ! defined $arg->{'fn'} || 
	             ($arg->{'fn'} eq '')) 
		{ die "Call to stat_file() failed, value associated w/ key 'fn' was undef/empty string"; }

	# This function defines keys (in $self):
	#
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

	# Test filename argument: verify that file exists on filesystem.

	if (! -e $arg->{'fn'} || 
	    ! -f $arg->{'fn'}) {

		return (undef);
	}

	# Call stat() to retreive file attributes.

	($self->{'f_dev'}, 
	 $self->{'f_ino'}, 
	 $self->{'f_mode'}, 
	 $self->{'f_nlink'}, 
	 $self->{'f_uid'}, 
	 $self->{'f_gid'}, 
	 $self->{'f_rdev'}, 
	 $self->{'f_size'}, 
	 $self->{'f_atime'}, 
	 $self->{'f_mtime'}, 
	 $self->{'f_ctime'}, 
	 $self->{'f_blksize'}, 
	 $self->{'f_blocks'}) 
	   = stat ($arg->{'fn'});

	return (1);
}

sub read_file {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to read_file() failed, argument must be hash reference"; }

	if (! exists  $arg->{'fn'} || 
	    ! defined $arg->{'fn'} || 
	             ($arg->{'fn'} eq '')) 
		{ die "Call to read_file() failed, value associated w/ key 'fn' was undef/empty string"; }

	# Test filename argument: verify that file exists on filesystem.

	if (! -e $arg->{'fn'} || 
	    ! -f $arg->{'fn'}) 
		{ return (undef); }

	my $fh;   # Filehandle

	             # _________________
	use bytes;   # Bytes pragma: ON.

	my ($buf);   # <--- Declare inside "use bytes" pragma.
	my (@fc);    # <--- Declare inside "use bytes" pragma.
	if (open ($fh, "<:raw", $arg->{'fn'})) 
	     { undef; }
	else { warn ("Function open() returned w/ error. ", $!, $^E); }

	if (binmode ($fh, ":raw")) 
	     { undef; }
	else { warn ("Function binmode() returned w/ error. ", $!, $^E); }

	no bytes;    # Bytes pragma: OFF.
	             # __________________

	while (my $rv = read ($fh, $buf, SZ_READ, 0)) 
		{ push @fc, split '', $buf; }

	close $fh;

	$self->{'fc'} = \@fc;

	return (1);
}

sub file_len {

	my $self = shift;

	# Check for acceptable value associated w/ key 'fl' (cached file length).

	if (! exists  $self->{'fl'} || 
	    ! defined $self->{'fl'} || 
	             ($self->{'fl'} eq '')) {

		# Check for value associated w/ key 'fc' (file contents: raw bytes).

		if (! exists  $self->{'fc'} || 
		    ! defined $self->{'fc'} || 
		    !  ((ref ($self->{'fc'})) eq 'ARRAY')) 
			{ return (undef); }

		# Calculate/store file length.

		my $fl = scalar (@{ $self->{'fc'} });
		if ($fl < 1) 
			{ return (undef); }
		$self->{'fl'} = $fl;
	}

	return ($self->{'fl'});
}

sub file_bytes {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to file_bytes() failed, argument must be hash reference"; }

	if (! exists  $arg->{'ofs'} || 
	    ! defined $arg->{'ofs'} || 
	             ($arg->{'ofs'} eq '')) 
		{ die "Call to file_bytes() failed, value associated w/ key 'ofs' was undef/empty string"; }

	if (! exists  $arg->{'len'} || 
	    ! defined $arg->{'len'} || 
	             ($arg->{'len'} eq '')) 
		{ die "Call to file_bytes() failed, value associated w/ key 'len' was undef/empty string"; }

	if (! exists  $arg->{'ofs'} || 
	    ! defined $arg->{'ofs'} || 
	           ! ($arg->{'ofs'} =~ /^\d+?$/) || 
	             ($arg->{'ofs'} > $self->file_len()) || 
	    ! exists  $arg->{'len'} || 
	    ! defined $arg->{'len'} || 
	           ! ($arg->{'len'} =~ /^\d+?$/) || 
	            (($arg->{'ofs'} + $arg->{'len'}) > $self->file_len())) {

		return (undef);
	}

	return (\@{ [ @{ $self->{'fc'} }[$arg->{'ofs'} .. (($arg->{'ofs'} + $arg->{'len'}) - 1)] ] });
}

sub insert_str {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to insert_str() failed, argument must be hash reference"; }

	if (! exists  $arg->{'pos'} || 
	    ! defined $arg->{'pos'} || 
	             ($arg->{'pos'} eq '') || 
	           ! ($arg->{'pos'} =~ /^\d+?$/)) 
		{ die "Call to insert_str() failed, value associated w/ key 'pos' must be one or more digits"; }

	if (! exists  $arg->{'str'} || 
	    ! defined $arg->{'str'} || 
	             ($arg->{'str'} eq '')) 
		{ die "Call to insert_str() failed, value associated w/ key 'str' was undef/empty string"; }

	# Determine file length. Verify that offset (where string to be 
	# inserted) is within bounds of the file.

	my $fl = $self->file_len();

	if (! defined $fl || 
	           ! ($fl =~ /^\d+?$/)) 
		{ return (undef); }

	if ($arg->{'pos'} > $fl) 
		{ die "Call to insert_str() failed, value associated w/ key 'pos' is greater than file length"; }

	my $unpack_str = ('a ' x length ($arg->{'str'}));
	my @str_bytes = unpack ($unpack_str, $arg->{'str'});
	if (! ($#str_bytes >= 0) || 
	    ! (scalar (@str_bytes) > 0)) 
		{ return (undef); }

	$self->{'fc'} =  
	   [ @{ $self->{'fc'} }[0 .. ($arg->{'pos'} - 1)], 
	     @str_bytes, 
	     @{ $self->{'fc'} }[$arg->{'pos'} .. ($fl - 1)] ];

	$self->{'fl'} = '';   # Invalidate cached file length (cause it to be updated on next call to file_len()).

	return (1);
}

sub write_file {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to read_file() failed, argument must be hash reference"; }

	if (! exists  $arg->{'fn'} || 
	    ! defined $arg->{'fn'} || 
	             ($arg->{'fn'} eq '')) 
		{ die "Call to read_file() failed, value associated w/ key 'fn' was undef/empty string"; }

	# Test filename argument: verify file exists.

	if (! -e $arg->{'fn'} || 
	    ! -f $arg->{'fn'}) {

		return (undef);
	}

	use bytes;   # Bytes pragma: ON.

	my ($buf);   # Declare inside "use bytes" pragma.
	my (@fc);    # Declare inside "use bytes" pragma.

        my $fh = IO::File->new ($arg->{'fn'}, O_WRONLY|O_CREAT);
        if (! (defined $fh)) {

		die "Function IO::File->new() returned w/ error (called w/ path=" . 
		    $arg->{'fn'} . ": ". $! . $^E;
	}

	if (! (binmode ($fh, ":raw"))) 
		{ warn ("Function binmode() returned w/ error. ", $!, $^E); }

	no bytes;    # Bytes pragma: OFF.

	my $pack_str = 'a' . $self->file_len();
	print $fh pack ($pack_str, (join ('', @{ $self->{'fc'} })));
	
	close $fh;

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::File (ZHex/File.pm) - File Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::File module defines functions which provide checking, opening, 
reading, and writing files which are being edited (within the hex editor).

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objFile = $self->{'obj'}->{'file'};
    $objFile->stat_file ({'fn' => $abspath_w_filename});

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 file_bytes
Method file_bytes()...
= cut

=head2 file_len
Method file_len()...
= cut

=head2 init
Method init()...
= cut

=head2 insert_str
Method insert_str()...
= cut

=head2 read_file
Method read_file()...
= cut

=head2 register_evt_callbacks
Method register_evt_callbacks()...
= cut

=head2 set_file
Method set_file()...
= cut

=head2 stat_file
Method stat_file()...
= cut

=head2 write_file
Method write_file()...
= cut

=head1 AUTHOR

Double Z, C<< <zacharyz at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ZHex at rt.cpan.org>, or 
via the web interface: L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ZHex>.  
I will be notified, and then you'll automatically be notified of progress on 
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ZHex

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ZHex>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ZHex>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ZHex>

=item * Search CPAN

L<http://search.cpan.org/dist/ZHex/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Double Z.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;

