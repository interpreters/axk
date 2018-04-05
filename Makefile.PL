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
        'Getopt::Long' => '0',
        'Pod::Usage' => '0',
        'Pod::Find' => '0',
        'Carp' => '0',
        #'Web::Query' => '0',
        #'Web::Query::LibXML' => '0',
        'Import::Into' => '0',
        'Object::Tiny::XS' => '0',
        'Tie::Scalar' => '0',
        'Tie::Array' => '0',
        'Tie::Hash' => '0',
        'XML::Handler::BuildDOM' => '0',
        'XML::LibXML::jQuery' => '0',
            # Maybe I only need HTML::Selector::XPath qw/selector_to_xpath/,
            # which X::L::jQuery uses.  TODO check this.
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'XML-Axk-*' },
);
# vi: set ts=4 sts=4 sw=4 et ai: #
