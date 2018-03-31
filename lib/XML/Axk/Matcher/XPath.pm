#!/usr/bin/env perl
# XML::Axk::Matcher::XPath - XPath matcher
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Matcher::XPath;
use XML::Axk::Base;

use Object::Tiny::XS qw(xpath);

sub test {
    my $self = shift;
    my $refData = shift or return false;
    eval {
        say "XPath: Attempt to match $self->xpath against $refData";
    };
    return true;    # for now
} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
