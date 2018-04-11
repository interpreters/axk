#!/usr/bin/env perl
# XML::Axk::Matcher::Selector - Selector matcher
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.

package XML::Axk::Matcher::Selector;
use XML::Axk::Base;

use Object::Tiny::XS qw(selector);

sub test {
    my $self = shift;
    my $refData = shift or return false;
    eval {
        say "Selector: Attempt to match $self->selector against $refData";
    };
    return true;    # for now
} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
