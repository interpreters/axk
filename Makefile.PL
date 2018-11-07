use 5.018;
use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;

# Get the filename of the Perl interpreter running this.  Modified from perlvar.
# The -x test is for cygwin or other systems where $Config{perlpath} has no
# extension and $Config{_exe} is nonempty.  E.g., symlink perl->perl5.10.1.exe.
# There is no "perl.exe" on such a system.
sub get_perl_filename {
    my $secure_perl_path = $Config{perlpath};
    if ($^O ne 'VMS') {
        $secure_perl_path .= $Config{_exe}
            unless (-x $secure_perl_path) ||
                            ($secure_perl_path =~ m/$Config{_exe}$/i);
    }
    return $secure_perl_path;
} # get_perl_filename()

my $secure_perl_path = get_perl_filename();

sub MY::postamble {     # TODO also handle Windows nmake syntax (SET vs. export)
    return <<EOT;
authortest:
\tRELEASE_TESTING=1 prove -l xt"

testhere:   # Run the tests from lib rather than blib
\t"$secure_perl_path" -Ilib -e 'use Test::Harness "runtests"; runtests \@ARGV;' -- t/*.t
EOT
} #postamble

WriteMakefile(
    NAME            => 'XML::Axk',
    AUTHOR          => q{Christopher White <cxwembedded@gmail.com>},
    VERSION_FROM    => 'lib/XML/Axk/App.pm',
    ABSTRACT        => 'awk-like XML processor',
    LICENSE         => 'artistic_2',
    EXE_FILES       => [ 'bin/axk' ],
    MIN_PERL_VERSION => '5.018',
    CONFIGURE_REQUIRES => {
        'Config' => '0',
        'ExtUtils::MakeMaker' => '0',
        'strict' => '0',
        'version' => '0.77',
        'warnings' => '0',
    },
    TEST_REQUIRES => {
        'Capture::Tiny' => '0',
        'File::Spec' => '0',
        'Module::Loaded' => '0',
        'parent' => '0',
        'rlib' => '0',
        'Test::More' => '0.92',
        'Test::Exception' => '0',
        'Test::Kit' => '0',
        'Test::Class' => '0',
        'Test::Class::Load' => '0',
    },
    PREREQ_PM => {
        'Carp' => '0',
        'Data::Dumper' => '0',
        'Exporter' => '0',
        'Getopt::Long' => '2.50',
        'Hash::Util::FieldHash' => '0',
        'HTML::Selector::XPath' => '0',
        'Import::Into' => '0',
        'Object::Tiny' => '0',
        'Pod::Find' => '0',
        'Pod::Usage' => '0',
        'Tie::Array' => '0',
        'Tie::Hash' => '0',
        'Tie::Scalar' => '0',
        'vars' => '0',
        #'Web::Query' => '0',
        #'Web::Query::LibXML' => '0',
        'XML::DOM' => '0',
        'XML::DOM::XPath' => '0',
        'XML::Handler::BuildDOM' => '0',
        'XML::SAX::ParserFactory' => '0',
        #'XML::LibXML::jQuery' => '0',
            # Do I actually need full X::L::jQuery?
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'XML-Axk-*' },
    depend => { Makefile => '$(VERSION_FROM)' },
);
# vi: set ts=4 sts=4 sw=4 et ai: #
