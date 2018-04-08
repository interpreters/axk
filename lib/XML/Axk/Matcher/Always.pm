#!/usr/bin/env perl
# XML::Axk::Matcher::Always - Always match or not
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Matcher::Always;
use XML::Axk::Base;

use Object::TinyDefaults { always => true };

sub test {
    my $self = shift;
    return $self->always;
} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
