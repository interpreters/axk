#!perl -T

package main;

use 5.018;
use strict;
use warnings;
use Test::More; # tests=>27;
use Capture::Tiny 'capture';

BEGIN {
    use_ok( 'XML::Axk::App' ) || print "Bail out!\n";
}

diag( "Testing XML::Axk::App $XML::Axk::App::VERSION, Perl $], $^X" );

# No defaults ===================================================== {{{1
package main {
    my ($out, $err) = do {
        # Close stdin.  TODO use IO::NestedCapture instead?
        close STDIN;
        open STDIN, '<', \'';
        capture { XML::Axk::App::Main(['-e','print 42']) };
    };
    is($out, '42', 'inline script runs');
}

# }}}1

done_testing();

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=0: #
