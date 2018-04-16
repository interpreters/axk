#!perl

package main;

use 5.018;
use strict;
use warnings;
use Test::More; # tests=>27;
use Capture::Tiny 'capture_stdout';
use File::Spec;

BEGIN {
    use_ok( 'XML::Axk::App' ) || print "Bail out!\n";
}

diag( "Testing XML::Axk::App $XML::Axk::App::VERSION, Perl $], $^X" );

sub localpath {
    state $voldir = [File::Spec->splitpath(__FILE__)];
    return File::Spec->catpath($voldir->[0], $voldir->[1], shift)
}

# Inline script =================================================== {{{1
package main {
    my $out = capture_stdout
                { XML::Axk::App::Main(['-e','print 42', '--no-input']) };
    is($out, '42', 'inline script runs');
}

# }}}1
# Script on disk ================================================== {{{1
package main {
    my $out =
        capture_stdout
            { XML::Axk::App::Main([ '-f', localpath('02.axk'), '--no-input']) };
    is($out, '1337', 'on-disk script runs');
}

# }}}1

done_testing();

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
