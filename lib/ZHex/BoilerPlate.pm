#!/usr/bin/perl

package ZHex::BoilerPlate;

use 5.006;
use strict;
use warnings FATAL => 'all';

BEGIN { require Exporter;
	our $VERS      = 0.01;
	our $VERSION   = $VERS;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw(new 
                            init 
                            obj_init
                            $VERS);
}

# Functions: Start-up/initialization.
#
#   _____________	___________
#   Function Name	Description
#   _____________	___________
#   new()		Object constructor method
#   init()		Global variable declarations
#   obj_init()		Takes arguement: reference to hash w/ key/value 
#   			pairs in the form: 
#   			    object_name => object_reference.
#   			Evaluates argument to make sure that key/value 
#   			pairs are defined, w/ value which refers to 
#   			correct type of object.
#                       Stores hash ref in:  $self->{'obj'}.

sub new {

	my $class = shift;

	my $self = {};
	bless $self, $class;
	$self->init (@_);

	return ($self);
}

# Function stub: init() function (used by modules with nothing to initialize).

sub init {

	my $self = shift;

	return (1);
}

# Object hash initialization function: used by all modules.

sub obj_init {

	my $self = shift;
	my $arg  = shift;

	if (! defined $arg || 
	      ! (ref ($arg) eq 'HASH')) 
		{ die "Call to obj_init() failed, argument must be hash reference"; }

	if (! exists  $arg->{'obj'} || 
	    ! defined $arg->{'obj'} || 
	      ! (ref ($arg->{'obj'}) eq 'HASH')) 
		{ die "Call to obj_init() failed, value associated w/ key 'obj' must be hash reference"; }

	# Verify that obj hash defines correct key/value pairs:
	#
	#   Hash Key	Perl Module	Package
	#   ________	___________	_______
	#   charmap	CharMap.pm	ZHex::CharMap
	#   console	Console.pm	ZHex::Console
	#   cursor	Cursor.pm	ZHex::Cursor
	#   debug	Debug.pm	ZHex::Debug
	#   display	Display.pm	ZHex::Display
	#   editor	Editor.pm	ZHex::Editor
	#   event	Event.pm	ZHex::Event
	#   eventloop	EventLoop.pm	ZHex::EventLoop
	#   file	File.pm		ZHex::File

	if (! exists  $arg->{'obj'}->{'charmap'} || 
	    ! defined $arg->{'obj'}->{'charmap'} || 
	      ! (ref ($arg->{'obj'}->{'charmap'}) eq 'ZHex::CharMap') || 

	    ! exists  $arg->{'obj'}->{'console'} || 
	    ! defined $arg->{'obj'}->{'console'} || 
	      ! (ref ($arg->{'obj'}->{'console'}) eq 'ZHex::Console') || 

	    ! exists  $arg->{'obj'}->{'cursor'} || 
	    ! defined $arg->{'obj'}->{'cursor'} || 
	      ! (ref ($arg->{'obj'}->{'cursor'}) eq 'ZHex::Cursor') || 

	    ! exists  $arg->{'obj'}->{'debug'} || 
	    ! defined $arg->{'obj'}->{'debug'} || 
	      ! (ref ($arg->{'obj'}->{'debug'}) eq 'ZHex::Debug') || 

	    ! exists  $arg->{'obj'}->{'display'} || 
	    ! defined $arg->{'obj'}->{'display'} || 
	      ! (ref ($arg->{'obj'}->{'display'}) eq 'ZHex::Display') || 

	    ! exists  $arg->{'obj'}->{'editor'} || 
	    ! defined $arg->{'obj'}->{'editor'} || 
	      ! (ref ($arg->{'obj'}->{'editor'}) eq 'ZHex::Editor') || 

	    ! exists  $arg->{'obj'}->{'event'} || 
	    ! defined $arg->{'obj'}->{'event'} || 
	      ! (ref ($arg->{'obj'}->{'event'}) eq 'ZHex::Event') || 

	    ! exists  $arg->{'obj'}->{'eventloop'} || 
	    ! defined $arg->{'obj'}->{'eventloop'} || 
	      ! (ref ($arg->{'obj'}->{'eventloop'}) eq 'ZHex::EventLoop') || 

	    ! exists  $arg->{'obj'}->{'file'} || 
	    ! defined $arg->{'obj'}->{'file'} || 
	      ! (ref ($arg->{'obj'}->{'file'}) eq 'ZHex::File')) 

		{ die "Call to obj_init() failed: argument 'obj' missing one (or more) required key/value pairs"; }

	# Store reference to obj hash in self.

	$self->{'obj'} = $arg->{'obj'};

	return (1);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::BoilerPlate (ZHex/BoilerPlate.pm) - BoilerPlate Module, ZebraHex Editor.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The ZHex::BoilerPlate module provides three functions which are used by 
submodules (files named ZHex/*.pm), they are:

    new()        Constructor method.
    init()       Function stub (for modules that don't need an init() function.
    obj_init()   Initialize table of references to each submodule.

Usage:

    # Define my own init() function.
    use ZHex::BoilerPlate qw(new obj_init $VERS);

    # Use stub function init().
    use ZHex::BoilerPlate qw(new init obj_init $VERS);

    ...

    # Access function defined within a different submodule (ZHex/Editor.pm).
    $self->{'obj'}->{'editor'}->scroll_up_1x_line();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 new
Method new()...
= cut

=head2 init
Method init()...
= cut

=head2 obj_init
Method obj_init()...
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

