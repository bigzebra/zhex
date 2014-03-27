use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'ZHex',
    AUTHOR           => q{Double Z <zacharyz@gmail.com>},
    VERSION_FROM     => 'lib/ZHex.pm',
    ABSTRACT_FROM    => 'lib/ZHex.pm',
    LICENSE          => 'Artistic_2_0',
    MAKE             => 'dmake',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Win32::Console' => 0,
        'IO::File'       => 0,
        'Getopt::Long'   => 0,
        'Time::HiRes'    => 0
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'ZHex-* t/test.txt' }
);


__END__

