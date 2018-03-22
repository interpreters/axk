#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

# Style note: Hungarian prefixes are used on scalars:
#   "hr" (hash ref), "lr" (list ref), "sr" (string ref), "nr" (numeric ref),
#   "dr" ("do," i.e., block ref), "ref" (unspecified ref),
#   "b" or "is" (boolean), "s" (string)

package XML::Axk::Core;
use XML::Axk::Base;

# a demo {{{1
say true;
our $x;
say \$x;
sub foo(&) {
    my $blk = shift;
    {
        local $x=128;
        say &$blk;
        say \$x;
    }
};

foo { \$x };
foo { foo { 42 } };
say 'end of demo';
# end of demo }}}1

package XML::Axk::Inner
{
    use Data::Dumper;
    use constant {true => !!1, false => !!0};
    my @worklist = ();  # array of [pattern, action] to try, in order
    sub stuff { say "inner"; };
# TODO define `our` variables usable in blocks {{{1

# }}}1
# TODO define subs to tag various things as, e.g., selectors, xpath, {{{1
# attributes, namespaces, ... .  This is essentially a DSL for all the ways
# you can write a pattern

# }}}1
# TODO define subs for the pattern/action pairs: pre, post, ... .  {{{1
# In each, test the pattern, and, if true, localize each of the `our`
# variables and call the action.

#}}}1

    ## @function public on (pattern, &action)
    ## The main way to define pattern/action pairs.
    ## @params required pattern     The pattern
    ## @params required &action     A block to execute when the pattern matches
    #sub on :prototype(\[$@%&]&) {
    sub on :prototype(*&) {
        say Dumper(@_);
        my $refPattern = shift;
        my $drAction = shift;
        #my $refPattern = shift;

        say 'in on() with ' . ref($refPattern) . ' = ' . $$refPattern;
        say 'in on()';
        push @worklist, [0, $drAction];

    } #on()

    sub run {
        foreach my $lrItem (@worklist) {
            my ($refPattern, $refAction) = @$lrItem;

            my $isMatch = true;    # TODO evaluate $refPattern
            next unless $isMatch;
            eval { &$refAction };
            #next unless @!;
            die "eval: $@" if $@;

            # Report errors
        }
    } #run()

    sub load_file {
        my $fn = shift;
        open(my $fh, '<', $fn) or die("Cannot open $fn");
        my $contents;
        {
            local $/;
            $contents = <$fh>;
        }
        close $fh;

        $fn =~ s{\\}{\\\\};
        $fn =~ s{'}{\\'};
        $contents = "#line 1 '$fn'\n" . $contents;
        say "Loading $contents";
        eval $contents;
        die "Could not parse '$fn': $@" if $@;
        say "Done";
    } #load_file

} # package XML::Axk::Inner

# Main {{{1
sub Main {
    # TODO read in the inputs as perl source in the context of axk::inner
    # TODO eval the inputs in the context of axk::inner
    axk::inner::stuff;
    axk::inner::load_file('foo.txt');
    axk::inner::run();
    return 0;
} #Main()

1;

# }}}1
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
