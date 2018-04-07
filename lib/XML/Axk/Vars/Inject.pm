#!/usr/bin/env perl
# XML::Axk::Vars::Inject - add script-accessible vars to the caller.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Vars::Inject;
use XML::Axk::Base;
use Import::Into;
use vars;

use XML::Axk::Vars::Scalar;
use XML::Axk::Vars::Array;

# Config: the variables to create.
# NOTE: these must be kept in sync with X::A::Core.  TODO fix this.
my @create_vars = qw($C @F $D $E);

# Helpers ======================================================== {{{2

sub inject_var {
    my ($instance, $target, $varname) = @_;
    my $basename = substr($varname, 1);
    no strict 'refs';

    if(substr($varname, 0, 1) eq '$') {         # scalar
        tie(${"${target}::${basename}"}, 'XML::Axk::Vars::Scalar',
            $instance, $basename);

    } elsif(substr($varname, 0, 1) eq '@') {    # array
        tie(@{"${target}::${basename}"}, 'XML::Axk::Vars::Array',
            $instance, $basename);

    } else {
        croak "Can't inject unknown var type $varname";
    }
} #inject_var()

# }}}2
# Export ========================================================= {{{1

# At compile time, just create the symbols but don't give them values
# or tie them.
sub import {
    vars->import::into(1, @create_vars);
} #import()


# At run-time, associated them with the values.
sub inject {
    my $class = shift;
    my $instance = shift or croak("No Core instance provided to XAVI::inject");
    my $target = caller;

    # Link the variables in $target to $instance
    inject_var $instance, $target, $_ foreach @create_vars;
} #inject()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=1: #
