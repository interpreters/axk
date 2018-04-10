#!/usr/bin/env perl
# XML::Axk::Vars::Scalar - tie a scalar to a member in X::A::Core.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Vars::Scalar;
use XML::Axk::Base;

use Tie::Scalar;
use parent -norequire => 'Tie::StdScalar';

# Tie methods ==================================================== {{{1

# Create a scalar tied to a script-accessible var in an XAC instance
# @param $class
# @param $instance  XML::Axk::Core instance
# @param $varname   Name of the new variable
sub TIESCALAR {
    my $class = shift;
    my $instance = shift or croak('No instance');
    my $lang = shift or croak('No language name');
    my $varname = shift or croak("No varname");     # the var to create

    #say "Tying scalar \$$varname to $instance";
    return bless \($instance->{sp}->{$lang}->{$varname}), $class;
} #TIESCALAR()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=2: #
