#!/usr/bin/env perl
# XML::Axk::V1 - axk language, version 1
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::V1;
use XML::Axk::Base;
use XML::Axk::Core;

# Exports to the user's scripts ================================== {{{1

use XML::Axk::ScriptAccessibleVars;     # To re-export

# Exports from this file, exported by import()'s call to export_to_level()
use parent 'Exporter';
our @EXPORT = qw(pre_all pre_file on post_file post_all);

# }}}1
# TODO define subs to tag various things as, e.g., selectors, xpath, {{{1
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# }}}1
# Definers for special-case actions ============================== {{{1
sub pre_all :prototype(&) {
    push @XML::Axk::Core::pre_all, shift;
} #pre_all()

sub pre_file :prototype(&) {
    push @XML::Axk::Core::pre_file, shift;
} #pre_file()

sub post_file :prototype(&) {
    push @XML::Axk::Core::post_file, shift;
} #post_file()

sub post_all :prototype(&) {
    push @XML::Axk::Core::post_all, shift;
} #post_all()

# }}}1
# Definers for node actions ====================================== {{{1
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

# }}}1
# import ========================================================= {{{1
sub import {

    # Copy symbols listed in @EXPORT first, in case @_ gets trashed later
    shift->export_to_level(1, @_);   # from Exporter

    # Re-export
    my $target = caller;
    XML::Axk::ScriptAccessibleVars->import::into($target);
}; #import()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
