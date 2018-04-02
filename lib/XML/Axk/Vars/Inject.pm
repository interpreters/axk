#!/usr/bin/env perl
# XML::Axk::Vars::Inject - add script-accessible vars to the caller.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::Vars::Inject;
use XML::Axk::Base;
use Import::Into;

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

    do {
        no strict 'refs';
        #say "Injecting into $target\n" . Dumper(\%{"${target}::"});
        #say 'tie SAV: ',Dumper($instance);
    };

    # Create variables in $target linked to $instance
    do {
        no strict 'refs';
            # This doesn't work:
            #local $C;   # don't want to share this with other instances.
            #tie $C, 'XML::Axk::Vars::Scalar', $instance, "C";
            #${"${target}::C"} = $C;     # nope - tying doesn't propagate across assignment

        # *{"${target}::C"} = '';     # not the same as our package var - ** Do we need this?
        tie ${"${target}::C"}, 'XML::Axk::Vars::Scalar', $instance, "C";
        #say "$target is:\n" . Dumper(\%{"${target}::"});

        #local @F;
        tie @{"${target}::F"}, 'XML::Axk::Vars::Array', $instance, "F";

        say join ' ', 'inject->import $C', \${"${target}::C"}, '@F',\@{"${target}::F"};
    };

    #XML::Axk::Vars::Scalar->import::into($target, $instance, "C");
    #XML::Axk::Vars::Array->import::into($target, $instance, "F");

} #import()

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=1: #
