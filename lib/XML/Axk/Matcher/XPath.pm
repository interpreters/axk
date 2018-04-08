#!/usr/bin/env perl
# XML::Axk::Matcher::XPath - XPath matcher
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Matcher::XPath;
use XML::Axk::Base qw(:default any);
use XML::Axk::DOM;

our $VERBOSE = 0;

sub _dump {
    local $Data::Dumper::Maxdepth = 2;
    Dumper @_;
} #_dump()

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

    # Keep a real copy, not a reference
    $self->{xpath} = ${$self->xpath} if ref $self->xpath;

    return $self;
} #new()

sub test {
    my $self = shift;
    my $hrSAV = shift or return false;

    eval {
        say "XPath: Attempt to match `$self->{xpath}' in ", $self->file,
        ' at ', $self->line, ' against ', ref $hrSAV->{E};
        say _dump $hrSAV if $VERBOSE>1;
    } if $VERBOSE>0;

    my @matches = $hrSAV->{D}->findnodes($self->xpath);
    say "XPath matches: ", _dump(\@matches) if $VERBOSE>0;
    return any { $_ == $hrSAV->{E} } @matches;

    #return $hrSAV->{E}->matches($self->xpath);
    #   didn't work - maybe becase we weren't starting from the root?

} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
