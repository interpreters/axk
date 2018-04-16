use 5.018;
use strict;
use warnings;
use ExtUtils::MakeMaker;

sub MY::postamble {
    return "authortest:\n\tRELEASE_TESTING=1 prove -l xt";
}

WriteMakefile(
    NAME            => 'XML::Axk',
    AUTHOR          => q{Christopher White <cxwembedded@gmail.com>},
    VERSION_FROM    => 'lib/XML/Axk.pm',
    ABSTRACT_FROM   => 'lib/XML/Axk.pm',
    LICENSE         => 'artistic_2',
    EXE_FILES       => [ 'bin/axk' ],
    MIN_PERL_VERSION => '5.018',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
        'version' => '0.77',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0.92',
        'Capture::Tiny' => '0',
        'Module::Loaded' => '0',
        'File::Spec' => '0',
    },
    PREREQ_PM => {
        'Data::Dumper' => '0',
        'Getopt::Long' => '2.50',
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
        'XML::DOM::XPath' => '0',
        'XML::Handler::BuildDOM' => '0',
        'HTML::Selector::XPath' => '0',
        #'XML::LibXML::jQuery' => '0',
            # Do I actually need full X::L::jQuery?
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'XML-Axk-*' },
    depend => { Makefile => '$(VERSION_FROM)' },
);
# vi: set ts=4 sts=4 sw=4 et ai: #
