#!/usr/bin/env perl
# XML::Axk::Vars::Array - tie an array to a member in X::A::Core.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Vars::Array;
use XML::Axk::Base;

use Tie::Array;
use parent -norequire => 'Tie::StdArray';

# Tie methods ==================================================== {{{1

# Create an array tied to a script-accessible var in an XAC instance
# @param $class
# @param $instance  XML::Axk::Core instance
# @param $varname   Name of the new variable
sub TIEARRAY {
    my $class = shift;
    my $instance = shift or croak('No instance');
    my $varname = shift or croak("No varname");     # the var to create

    #say "Tying array \$$varname to $instance";
    return bless $instance->{sav}->{$varname}, $class;
} #TIEARRAY()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=2: #
