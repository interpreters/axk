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
    say 'TIESCALAR: ', Dumper(\@_);
    my $class = shift;
    my $instance = shift or croak('No instance');
    my $varname = shift or croak("No varname");     # the var to create

    say "Tying scalar \$$varname to $instance";
    $instance->{sav}->{$varname} = undef;
    return bless \($instance->{sav}->{$varname}), $class;
} #TIESCALAR()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=2: #
