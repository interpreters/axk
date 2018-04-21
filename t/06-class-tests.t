#!perl
# 06-class-tests.t: Run t/tests

use 5.018;
use strict;
use warnings;
use lib 't/lib';
use Test::Class::Load qw(t/tests);
Test::Class->runtests;

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
