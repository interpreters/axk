#!/usr/bin/env perl
# XML::Axk::Matcher::XPath - XPath matcher
# Reminder: all matchers define test($refdata)->bool.
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.

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

    # Works, but slow
    #my @matches = $hrSAV->{D}->findnodes($self->xpath);
    #say "XPath matches: ", _dump(\@matches) if $VERBOSE>0;
    #return any { $_ == $hrSAV->{E} } @matches;

    # Works.  We have to use the xp directly because XML::DOM::XPath v0.14 L59
    # (https://metacpan.org/source/MIROD/XML-DOM-XPath-0.14/XPath.pm#L59)
    # swaps the order of the document and node parameters in the call to
    # xp->matches().
    return $hrSAV->{'$D'}->xp->matches($hrSAV->{'$E'}, $self->xpath, $hrSAV->{'$D'});
        # Match {E} against path xpath, in context {D}.

    #return $hrSAV->{D}->matches($hrSAV->{E}, $self->xpath);    # nope
    #   XML::DOM::XPath doesn't provide a $context parameter for
    #   Document->matches().

    #return $hrSAV->{E}->matches($self->xpath);
    #   didn't work - maybe becase we weren't starting from the root?

} #test()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker: #
