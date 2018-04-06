#!/usr/bin/env perl
# XML::Axk::SAX::Handler - Process an XML file using SAX.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.
# I am using SAX rather than XML::LibXML::Reader because I want full control
# over the DOM document throughout the processing.

package XML::Axk::SAX::Handler;
use XML::Axk::Base;

use parent 'XML::Handler::BuildDOM';
# General strategy: when encountering an element, call SUPER, then process.
# When leaving an element, process, call SUPER, then remove the node we just
# left from the DOM to keep the memory consumption down.

sub new
{
    my ($class, $core, @args) = @_;
    croak "Need an XML::Axk::Core" unless ref $core eq "XML::Axk::Core";

    my $self = $class->SUPER::new(@args);
    $self->{axkcore} = $core;
    return $self;
}

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=2: #
