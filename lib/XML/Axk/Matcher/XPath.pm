#!/usr/bin/env perl
# XML::Axk::Matcher::XPath - XPath matcher
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Matcher::XPath;
use XML::Axk::Base;

use Object::TinyDefaults
    {   kind => 'xpath',
        file => '(unknown source)',
        line => 0
    },
    qw(xpath);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    croak "No xpath specified" unless $self->{xpath};

    return $self;
} #new()

sub test {
    my $self = shift;
    my $refData = shift or return false;

    eval {
        say "XPath: Attempt to match `${$self->xpath}' against `$$refData` in ",
        $self->file, ' at ', $self->line;
    };
    return true;    # for now
} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
