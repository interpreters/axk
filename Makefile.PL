use 5.018;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'XML::Axk',
    AUTHOR          => q{Christopher White <cxwembedded@gmail.com>},
    VERSION_FROM    => 'lib/XML/Axk.pm',
    ABSTRACT_FROM   => 'lib/XML/Axk.pm',
    LICENSE         => 'artistic_2',
    PL_FILES        => {},
    EXE_FILES       => [ 'bin/axk' ],
    MIN_PERL_VERSION => '5.018',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'Data::Dumper' => '0',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'XML-Axk-*' },
);
# vi: set ts=4 sts=4 sw=4 et ai: #
