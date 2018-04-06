#!/usr/bin/env perl
# XML::Axk::V1 - axk language, version 1
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

# TODO:
# - Add a way to mark that a node should be kept in the DOM, even if running
#   in SAX mode (`stash`?)
# - Add a way to re-use the last pattern (`ditto`?)
# - Instead of using $_AxkCore, use a static map in XAC that goes from
#   the caller's package name to the corresponding core.
# - Add a static method to XAC to get the next package name, so that each
#   `axk_script_*` is used by only one Core instance.

package XML::Axk::V1;
use XML::Axk::Base;
use XML::Axk::Core;

use XML::Axk::Matcher::XPath;
use HTML::Selector::XPath qw(selector_to_xpath);

use Scalar::Util qw(reftype);

use parent 'Exporter';
our @EXPORT = qw(pre_all pre_file post_file post_all perform always xpath);

# Internal routines ============================================== {{{1

# Accessor
sub _core {
    my $home = caller(1);
    #say "_core from $home";
    no strict 'refs';
    my $core = ${"${home}::_AxkCore"};
    return $core;
} #_core()

# }}}1
# Definers for special-case actions ============================== {{{1

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
sub perform :prototype(&@) {
    #say Dumper(\@_);
    my ($drAction, $refPattern, $is_post) = @_;

    $refPattern = \( my $temp = $refPattern ) unless ref($refPattern);

    my $core = _core or croak("Can't find core in perform");
    push @{$core->{worklist}}, [$refPattern, $drAction, !!$is_post];
} #perform()

# }}}1
# Definers for matchers ========================================== {{{1

# TODO define subs to tag various things as, e.g., selectors, xpath,
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# Always match - a regex that always matches
sub always :prototype() {
    return qr//;
} #always()

# Make an XPath matcher
sub xpath :prototype(@) {
    my $refExpr = shift or croak("No expression provided!");
    $refExpr = \( my $temp = $refExpr ) unless ref($refExpr);

    my (undef, $filename, $line) = caller;
    my $matcher = XML::Axk::Matcher::XPath->new(
        xpath => $refExpr,
        file=>$filename, line=>$line,
    );
    return $matcher;
} #xpath()

# Make a selector matcher
sub sel :prototype(@) {
    my $refExpr = shift or croak("No expression provided!");
    $refExpr = \( my $temp = $refExpr ) unless ref($refExpr);
    my $xp = selector_to_xpath $$refExpr;
    my (undef, $filename, $line) = caller;
    my $matcher = XML::Axk::Matcher::XPath->new(
        xpath => \$xp, type => 'selector',
        file=>$filename, line=>$line,
    );
    return $matcher;
} #sel()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
