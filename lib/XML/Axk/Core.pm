#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

# Style note: Hungarian prefixes are used on scalars:
#   "hr" (hash ref), "lr" (list ref), "sr" (string ref), "nr" (numeric ref),
#   "dr" ("do," i.e., block ref), "ref" (unspecified ref),
#   "b" or "is" (boolean), "s" (string)

package XML::Axk::Core;
use XML::Axk::Base;

## # a demo {{{1
## say true;
## our $x;
## say \$x;
## sub foo(&) {
##     my $blk = shift;
##     {
##         local $x=128;
##         say &$blk;
##         say \$x;
##     }
## };
##
## foo { \$x };
## foo { foo { 42 } };
## say 'end of demo';
## # end of demo }}}1

# Storage for routines defined by the user's scripts ==================== {{{1

# TODO is there any way to make these instance variables and still have them
# accessible to scripts, with reentrancy?  I suppose load_* could generate
# a temporary package name, put a reference to the instance in that package,
# and hardwire that package into each script.
#   - Looks like I might be able to do this with Eval::Context, but I'm not
#     sure if the package variables in X::A::V1 can reach those.
#   * If I just stuff a reference to the Core instance in the symbol table
#     of each script package at load time, the helpers in this file can use
#     `caller` to get that package name and then find the instance in question.
#   **Even better --- put a reference to the Core instance in a uniquely-named
#     variable in XAC, then put an `our $_XAC = $X::A::C::<whatever>;` at the
#     top of each script being evaluated.  Then use caller as noted in the
#     previous point and ${"${caller}::_XAC} in the V1 routines.

# Load these in the order they are defined in the scripts.
our @pre_all = ();      # List of \& to run before reading the first file
our @pre_file = ();     # List of \& to run before reading each file
our @worklist = ();     # List of [\&condition, \&action] for each node
our @post_file = ();    # List of \& to run after reading each file
our @post_all = ();     # List of \& to run after reading the last file

# }}}1
# Private vars ========================================================== {{{1

# For giving each script a unique package name - TODO move to XACPn
my $scriptnumber = 0;

# }}}1
# Loading =============================================================== {{{1

# Load the script file given in $_[0], but do not execute it
sub load_script_file {
    my $self = shift;

    my $fn = shift;
    open(my $fh, '<', $fn) or croak("Cannot open $fn");
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
    #$fn =~ s{\\}{\\\\}g;   # This doesn't seem to be necessary based on
                            # the regex given for #line in perlsyn.
    $fn =~ s{"}{-}g;
        # as far as I can tell, #line can't handle embedded quotes.

    $leader .= ";\n#line 1 \"$fn\"\n";
        # Extra ; so the #line directive is in its own statement.
        # Thanks to https://www.effectiveperlprogramming.com/2011/06/set-the-line-number-and-filename-of-string-evals/

    # Put the user's script in its own package
    $leader = "package axk_script_$scriptnumber {\n" .
        "use XML::Axk::Base;\n" .
        "use XML::Axk::Vars::Inject;\n" .
        'our $_AxkCore = $' . $self->global_name . ";\n" .
        "XML::Axk::Vars::Inject->inject(\$_AxkCore);\n" .
        $leader;
    $trailer .= "\n};\n";
    ++$scriptnumber;

    $contents = ($leader . $contents . $trailer);
    #say "Loading $contents";
    eval $contents;
    croak "Could not parse '$fn': $@" if $@;
    #say "Done";
} #load_script_file

# }}}1
# Running =============================================================== {{{1

# Check for matches
sub isMatch {   #static
    #say "isMatch: ", Dumper(\@_);
    my ($refPattern, $refLine) = @_;
    my $ty = ref $refPattern;
    #say "Pattern has type $ty";
    if($ty eq 'Regexp') {
        return $$refLine =~ $refPattern;
    } elsif($ty eq 'SCALAR') {      # matches if the line contains the scalar
        return index($$refLine, $$refPattern) != -1;
    } else {    # todo check ::can('test')?
        return $refPattern->test($refLine);       # TODO expand this
    }
} #isMatch()

# Run the loaded script(s).  Takes a list of inputs.  Strings are treated
# as filenames; references to strings are treated as raw data to be treated
# as if read off disk.

sub run {
    my $self = shift;

    foreach my $drAction (@{$self->{pre_all}}) {
        eval { &$drAction };   # which context are they evaluated in?
        croak "pre_all: $@" if $@;
    }

    foreach my $infn (@_) {
        my $fh;
        say "Processing $infn";

        # Clear the SAVs before each file for consistency.
        # TODO replace these with accesses to our own ties to these variables
        # for consistency and clarity.
        $self->{sav}->{C}=undef;

        # Clear @F without replacing it so we don't break the tied variable's
        # reference to it.
        my @F = @{$self->{sav}->{F}};
        $#F = -1;   # empty @F without replacing it - http://www.perlmonks.org/?node_id=2264

        # For now, just process lines rather than nodes
        if($infn eq '-') {  # stdin
            open($fh, '<-') or croak "Can't open stdin!??!!";
        } else {            # disk file
            open($fh, "<", $infn) or croak "Can't open $infn: $!";
                # if $infn is a reference, its contents will be used -
                # http://www.perlmonks.org/?node_id=745018
        }

        foreach my $drAction (@{$self->{pre_file}}) {
            eval { &$drAction($infn) };   # which context are they evaluated in?
            croak "pre_file: $@" if $@;
        }

        my $FNR = 0;
        while(my $line = <$fh>) {
            say 'Line ', ++$FNR, '==========================';
            #say "Got $line";

            # Set the SAV values that can be accessed via ties in the user's scripts
            $self->{sav}->{C} = $line;  #

            splice(@F);
            #$#F = -1;   # replace contents of @F without moving it
            push @{$self->{sav}->{F}}, split(' ', $line);
            # doesn't work => push @F, split(' ', $line);

            #say "core: " , Dumper($self);
            say join ' ', 'main loop $C',\$self->{sav}->{C},'@F',$self->{sav}->{F};
                # @F is a $ because {sav} holds F as a \@

            foreach my $lrItem (@{$self->{worklist}}) {
                my ($refPattern, $refAction) = @$lrItem;

                next unless isMatch($refPattern, \$line);

                eval { &$refAction };   # which context are they evaluated in?
                croak "action: $@" if $@;
            }
        } # foreach line

        foreach my $drAction (@{$self->{post_file}}) {
            # TODO? make the last-seen node available to the action?
            # Similar to awk, in which the END block sees the last line as $0.
            eval { &$drAction($infn) };   # which context are they evaluated in?
            croak "post_file: $@" if $@;
        }

        close($fh) or warn "close failed: $!";

    } #foreach input filename

    foreach my $drAction (@{$self->{post_all}}) {
        # TODO? pass the last-seen node? (see note above)
        eval { &$drAction };   # which context are they evaluated in?
        croak "post_all: $@" if $@;
    }

} #run()

# }}}1
# Constructor, private data, and accessors ============================== {{{1

sub _globalname {   # static int->str
    my $idx = shift;
    return "XML::Axk::Core::_I${idx}";
} #_globalname()

# For giving each instance of Core a unique package name (X::A::C::P<n>)
my $_instance_number = 0;

sub new {
    my $class = shift;

    # Create the instance.
    my $data = {
        _id => ++$_instance_number,
        pre_all => [],
        pre_file => [],
        worklist => [],
        post_file => [],
        post_all => [],
        sav => {},      # X::A::SAV will add elements to this hash
    };
    my $self = bless($data, $class);

    # Load this instance into the global namespace so the Vn packages can
    # get at it
    do {
        no strict 'refs';
        ${_globalname($_instance_number)} = $self;
    };

    return $self;
} #new()

# RO accessors
sub id {
    return shift->{_id};
}

sub global_name {
    return _globalname(shift->{_id});
}

# }}}1

# No import() --- callers should refer to the symbols with their
# fully- qualified names.
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
