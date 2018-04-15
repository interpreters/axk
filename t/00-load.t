#!perl -T
use 5.018;
use strict;
use warnings;
use Test::More tests=>3;
use Module::Loaded;

BEGIN {
    use_ok( 'XML::Axk' ) || print "Bail out!\n";
}

diag( "Testing XML::Axk $XML::Axk::VERSION, Perl $], $^X" );
ok(is_loaded("XML::Axk::App"), "App is loaded");
ok(is_loaded("XML::Axk::Core"), "Core is loaded");

# vi: set ts=4 sts=4 sw=4 et ai: #
