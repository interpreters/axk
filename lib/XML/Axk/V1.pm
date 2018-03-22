#!/usr/bin/env perl
# XML::Axk::V1 - axk language, version 1
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::V1;
use XML::Axk::Base;

# TODO define `our` variables usable in blocks {{{1

# }}}1
# TODO define subs to tag various things as, e.g., selectors, xpath, {{{1
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# }}}1
# TODO define subs for the pattern/action pairs: pre, post, ... .  {{{1
# In each, test the pattern, and, if true, localize each of the `our`
# variables and call the action.

#}}}1

## @function public on (pattern, &action)
## The main way to define pattern/action pairs.
## @params required pattern     The pattern
## @params required &action     A block to execute when the pattern matches
#sub on :prototype(\[$@%&]&) {
sub on :prototype(*&) {
    say Dumper(@_);
    my $refPattern = shift;
    my $drAction = shift;
    #my $refPattern = shift;

    eval {
        say 'in on() with ' . ref($refPattern) . ' = ' . $$refPattern;
    };
    say 'in on()';
    push @XML::Axk::Core::worklist, [0, $drAction];

} #on()

sub import {
    feature->import(':5.18');
    strict->import;
    warnings->import;
    Carp->import;

    # Copy symbols.
    my $caller = caller(0);     # get the importing package name

    do {
        no strict 'refs';
        *{"$caller\:\:on"}  = *{"on"};
    };
}; #import()

1;

# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
