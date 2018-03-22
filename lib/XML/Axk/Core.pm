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

our @worklist = ();  # list of [pattern, action] to try, in order of definition

my $scriptnumber = 0;

# Load the script file given in $_[0], but do not execute it
sub load_script {
    my $fn = shift;
    open(my $fh, '<', $fn) or die("Cannot open $fn");
    my $contents;
    {
        local $/;
        $contents = <$fh>;
    }
    close $fh;

    # Permit users to specify the axk language version using `Vn` pragmas.
    # E.g., V1 (= V 1, V01, V001, ...) is specified in XML::Axk::V1.
    # The `V` must be the first non-whitespace on the line.
    # An axk script without a Vn pragma is an error.
    $contents =~ s{^\h*V\h*0*(\d+)\h*;?}{use XML::Axk::V$1;}m;

    # Text to wrap around the script
    my ($leader, $trailer) = ('', '');

    # Mark the filename for the sake of error messages
    $fn =~ s{\\}{\\\\};
    $fn =~ s{'}{\\'};
    $leader .= "#line 1 '$fn'\n";

    # Put the user's script in its own package
    $leader = "package axk_script_$scriptnumber {\n" . $leader;
    $trailer .= "\n};\n";
    ++$scriptnumber;

    $contents = ($leader . $contents . $trailer);
    say "Loading $contents";
    eval $contents;
    die "Could not parse '$fn': $@" if $@;
    say "Done";
} #load_script

# Run the loaded script(s)
sub run {
    foreach my $lrItem (@worklist) {
        my ($refPattern, $refAction) = @$lrItem;

        my $isMatch = true;    # TODO evaluate $refPattern
        next unless $isMatch;
        eval { &$refAction };   # which context are they evaluated in?
        #next unless @!;
        die "eval: $@" if $@;

        # Report errors
    }
} #run()

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
