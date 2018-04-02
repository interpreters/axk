#!/usr/bin/env perl
# XML::Axk::Vars::Inject - add script-accessible vars to the caller.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Vars::Inject;
use XML::Axk::Base;
use Import::Into;
use vars;

use XML::Axk::Vars::Scalar;
use XML::Axk::Vars::Array;

# Variables ====================================================== {{{1
# Note: `our` variables are shared between all running scripts.
our $foo = 'Hello, world!  from ScriptAccessibleVars';

our $C;     # the current line
our @F;     # The fields in the current line

# }}}1
# Export ========================================================= {{{1
use parent 'Exporter';
our @EXPORT = qw($foo $C @F);
# At compile time, just create the symbols but don't give them values
# or tie them.

# At run-time, associated them with the values.
sub inject {
    my $class = shift;
    my $instance = shift or croak("No Core instance provided to XAVI::inject");
    my $target = caller;

    # Link the variables in $target to $instance
    do {
        no strict 'refs';
        # *{"${target}::C"} = '';     # not the same as our package var - ** Do we need this?
        $instance->{sav_ties}->{C} =
            tie ${"${target}::C"}, 'XML::Axk::Vars::Scalar', $instance, "C";

        $instance->{sav_ties}->{F} =
            tie @{"${target}::F"}, 'XML::Axk::Vars::Array', $instance, "F";

    };

} #import()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=1: #
