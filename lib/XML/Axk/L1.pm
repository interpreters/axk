#!/usr/bin/env perl
# XML::Axk::L1 - axk language, version 1
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.

# TODO:
# - Add a way to mark that a node should be kept in the DOM, even if running
#   in SAX mode (`stash`?)
# - Add a way to re-use the last pattern (`ditto`?)
# - Add a static method to XAC to get the next package name, so that each
#   `axk_script_*` is used by only one Core instance.

package XML::Axk::L1;
use XML::Axk::Base qw(:default now_names);

use XML::Axk::Matcher::XPath;
use XML::Axk::Matcher::Always;
use HTML::Selector::XPath qw(selector_to_xpath);

use Scalar::Util qw(reftype);

# Packages we invoke by hand
require XML::Axk::Language;
require Exporter;
our @EXPORT = qw(
    pre_all pre_file post_file post_all perform
    always never xpath sel on run);
our @EXPORT_OK = qw( @SP_names );

# Helpers ======================================================== {{{1

# Accessor
sub _sandbox {
    my $home = caller(1);
    no strict 'refs';
    return ${"${home}::_AxkSandbox"};
} #_sandbox()

# }}}1
# Definers for special actions==================================== {{{1

sub pre_all :prototype(&) {
    my $sandbox = _sandbox or croak("Can't find sandbox in pre_all");
    #say "core: " . Dumper($sandbox);
    #say Dumper($sandbox->{pre_all});
    #say Dumper(@{$sandbox->{pre_all}});
    push @{$sandbox->pre_all}, shift;
} #pre_all()

sub pre_file :prototype(&) {
    my $sandbox = _sandbox or croak("Can't find sandbox in pre_file");
    push @{$sandbox->pre_file}, shift;
} #pre_file()

sub post_file :prototype(&) {
    my $sandbox = _sandbox or croak("Can't find sandbox in post_file");
    push @{$sandbox->post_file}, shift;
} #post_file()

sub post_all :prototype(&) {
    my $sandbox = _sandbox or croak("Can't find sandbox in post_all");
    push @{$sandbox->post_all}, shift;
} #post_all()

# }}}1
# Definers for node actions ====================================== {{{1

## @function public perform (&action[, pattern[, when]])
## The main way to define pattern/action pairs.  This takes the action first
## since that's how Perl's prototypes are set up the cleanest (block first).
## @params required &action     A block to execute when the pattern matches
## @params required pattern     The pattern
sub add_to_worklist {
    #say "add_to_worklist args: ", Dumper(\@_);
    my ($drAction, $refPattern, $when) = @_;
    #say "perform(): ", Dumper(\@_);
    $when = $when // HI;    # only on entry, by default

    $refPattern = \( my $temp = $refPattern ) unless ref($refPattern);

    # TODO? support Regexp, scalar patterns in some sensible way

    my $sandbox = _sandbox or croak("Can't find sandbox in perform");
    push @{$sandbox->worklist}, [$refPattern, $drAction, $when];
} #perform()

# User-facing alias for add_to_worklist
sub perform :prototype(&@) {
    goto &add_to_worklist;  # Need goto so that _sandbox() can use caller(1)
}

# run { action } [optional <when>] - syntactic sugar for sub {}, when
sub run :prototype(&;$) {
    return @_;
} #run()

# pattern-first style - on {} run {} [when];
sub on :prototype(&@) {
    my ($drMakeMatcher, $drAction, $when) = @_;

    #say "MakeMatcher: ", Dumper($drMakeMatcher);
    my $matcher = &$drMakeMatcher;
    #say "Matcher: ", Dumper($matcher);

    @_=($drAction, $matcher, $when);
    goto &add_to_worklist;
} # on()

# }}}1
# Definers for matchers ========================================== {{{1

# TODO define subs to tag various things as, e.g., selectors, xpath,
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# Always match
sub always :prototype() {
    return XML::Axk::Matcher::Always->new();
} #always()

# Never match - for easily turning off a particular clause
sub never :prototype() {
    return XML::Axk::Matcher::Always->new(always => false);
} #never()

# Make an XPath matcher
sub xpath {
    my $path = shift or croak("No expression provided!");
    $path = $$path if ref $path;

    my (undef, $filename, $line) = caller;
    my $matcher = XML::Axk::Matcher::XPath->new(
        xpath => $path,
        file=>$filename, line=>$line,
    );
    return $matcher;
} #xpath()

# Make a selector matcher
sub sel {
    my $path = shift or croak("No expression provided!");
    $path = $$path if ref $path;

    my $xp = selector_to_xpath $path;
    my (undef, $filename, $line) = caller;
    my $matcher = XML::Axk::Matcher::XPath->new(
        xpath => $xp, type => 'selector',
        file=>$filename, line=>$line,
    );
    return $matcher;
} #sel()

# }}}1

# Script parameters ============================================== {{{1

# Script-parameter names
our @SP_names = qw($C @F $D $E $NOW);

sub update {
    #say "L1::update: ", Dumper(\@_);
    my $hrSP = shift or croak("No hrSP");
    my %opts = @_;

    $hrSP->{'$D'} = $opts{document} or croak("No document");
    $hrSP->{'$E'} = $opts{record} or croak("No record");
    croak("You are in a timeless maze") unless defined $opts{NOW};
    $hrSP->{'$NOW'} = now_names $opts{NOW};
    #while (my ($key, $value) = each %new_sps) { }
} #update()

# }}}1

# Import ========================================================= {{{1

sub import {
    #say "update: ",ref \&update, Dumper(\&update);
    my $target = caller;
    #say "XAL1 run from $target:\n", Devel::StackTrace->new->as_string;
    XML::Axk::Language->import(
        target => $target,
        sp => \@SP_names,
        updater => \&update
    );
        # By doing this here rather than in the `use` statement,
        # we get $target and don't have to walk the stack to find the
        # axk script.
    goto &Exporter::import;     # for @EXPORT &c.  @_ is what it was on entry.
} #import()

#}}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
