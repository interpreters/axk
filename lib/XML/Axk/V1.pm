#!/usr/bin/env perl
# XML::Axk::V1 - axk language, version 1
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::V1;
use XML::Axk::Base;
use XML::Axk::Core;

use XML::Axk::Matcher::XPath;

use parent 'Exporter';
our @EXPORT = qw(pre_all pre_file post_file post_all perform xpath);

# Definers for special-case actions ============================== {{{1

# Accessor
sub _core {
    my $home = caller(1);
    #say "_core from $home";
    no strict 'refs';
    my $core = ${"${home}::_AxkCore"};
    return $core;
} #_core()

sub pre_all :prototype(&) {
    my $core = _core or croak("Can't find core in pre_all");
    #say "core: " . Dumper($core);
    #say Dumper($core->{pre_all});
    #say Dumper(@{$core->{pre_all}});
    push @{$core->{pre_all}}, shift;
} #pre_all()

sub pre_file :prototype(&) {
    my $core = _core or croak("Can't find core in pre_file");
    push @{$core->{pre_file}}, shift;
} #pre_file()

sub post_file :prototype(&) {
    my $core = _core or croak("Can't find core in post_file");
    push @{$core->{post_file}}, shift;
} #post_file()

sub post_all :prototype(&) {
    my $core = _core or croak("Can't find core in post_all");
    push @{$core->{post_all}}, shift;
} #post_all()

# }}}1
# Definers for node actions ====================================== {{{1

## @function public on (pattern, &action)
## The main way to define pattern/action pairs.  This takes the action first
## since that's how Perl's prototypes are set up the cleanest (block first).
## @params required &action     A block to execute when the pattern matches
## @params required pattern     The pattern
use Scalar::Util qw(reftype);
sub perform :prototype(&@) {
    #say Dumper(\@_);
    my $drAction = shift;
    my $refPattern = shift;

    $refPattern = \( my $temp = $refPattern ) unless ref($refPattern);

    my $core = _core or croak("Can't find core in perform");
    push @{$core->{worklist}}, [$refPattern, $drAction];
} #perform()

# Make an XPath matcher
sub xpath :prototype(@) {
    my $refExpr = shift or croak("No expression provided!");
    $refExpr = \( my $temp = $refExpr ) unless ref($refExpr);
    my $matcher = XML::Axk::Matcher::XPath->new(xpath => $refExpr);
    return $matcher;
} #xpath()

# }}}1
# TODO define subs to tag various things as, e.g., selectors, xpath, {{{1
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
