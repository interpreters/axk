#!perl -T
use 5.018;
use strict;
use warnings;
use Test::More tests=>5;
use Module::Loaded;

BEGIN {
    use_ok( 'XML::Axk' ) || print "Could not load main\n";
    use_ok( 'XML::Axk::App' ) || print "Could not load App\n";
    use_ok( 'XML::Axk::Core' ) || print "Could not load Core\n";
}

diag( "Testing XML::Axk $XML::Axk::VERSION, Perl $], $^X" );
ok(is_loaded("XML::Axk::App"), "App is loaded");
ok(is_loaded("XML::Axk::Core"), "Core is loaded");

# vi: set ts=4 sts=4 sw=4 et ai: #
