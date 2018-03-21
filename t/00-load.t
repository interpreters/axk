#!perl -T
use 5.018;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'XML::Axk' ) || print "Bail out!\n";
}

diag( "Testing XML::Axk $XML::Axk::VERSION, Perl $], $^X" );
