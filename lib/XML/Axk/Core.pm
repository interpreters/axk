#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

# Style note: Hungarian prefixes are used on scalars:
#   "hr" (hash ref), "lr" (list ref), "sr" (string ref), "nr" (numeric ref),
#   "dr" ("do," i.e., block ref), "ref" (unspecified ref),
#   "b" or "is" (boolean), "s" (string)

package XML::Axk::Core;
use XML::Axk::Base qw(:all);
use XML::Axk::Language ();

# TODO
# - throughout: Rename SAVs to SPs (Script Parameters).
# - DONE Add an SP registry to new X::A::LangBase.  Each XALn uses LangBase and
#   registers itself in the SP registry.
# - DONE Each XALn croaks if another Ln is already loaded.
# - DONE Each XALn stores its package name in `our $_AxkLang` in each script
# - Update XAVI: pull the vars from the SP registry based on $_AxkLang.
#   If the SP slots don't exist in the XAC instance, create them.

# Private vars ========================================================== {{{1

# For giving each script a unique package name
my $scriptnumber = 0;

# }}}1
# Loading =============================================================== {{{1

# Load the named script file from disk, but do not execute it
# @param $self
# @param $fn {String}   Filename to load
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

    $self->load_script_text($contents, $fn, false);
        # false => scripts on disk MUST specify a Ln directive.  This is a
        # design decision, so we don't have issues like Perl 5/6 or Python 2/3.

} #load_script_file

# Load the given text, but do not execute it.
# @param $self
# @param $text {String} The source text
# @param $fn {String}   Filename to use in debugging messages
# @param $add_Ln {boolean, default false} If true, add a Ln directive for the
#           current version if there isn't one in the script.
sub load_script_text {
    my $self = shift;
    my $text = shift;
    my $fn = shift // '(command line)';
    my $add_Ln = shift;

    # Text to wrap around the script
    my ($leader, $trailer) = ('', '');

=pod

=head1 SPECIFYING THE AXK LANGUAGE VERSION

An axk script can include a C<Ln> pragma that specifies the axL1
language version in use.  For example, C<L1> (or, C<L 1>, C<L01>,
C<L001>, ...) calls for language version 1 (currently defined in
C<XML::Axk::L1>).  The C<Ln> must be the first non-whitespace item
on a line.

An axk script on disk without a Ln pragma is an error.  This means
that the language version must be specified in the C<Ln> form, not as
a direct C<use ...::Ln;> statement.  This is so that C<Ln> can expand
to something different depending on the language version, if
necessary.  However, you can say `use...Ln` manually _in addition to_
the pragma (e.g., in a different package).

Multiple C<Ln> pragmas are allowed in a file.  This is so you can use
different language versions in different packages if you want to.
However, you do so at your own risk!

Command-line scripts without a C<Ln> pragma use the latest version
automatically.  That is, the behaviour is like perl's C<-E> rather than
perl's C<-e>.  That risks breakage of inline scripts, but makes it easier
to use axk from the command line.  If you are using axk in a script,
specify the C<Ln> pragma at the beginning of your script.  This is
consistent with the requirement to list the version in your source
files.

=cut

    unless($text =~ s{^\h*L\h*0*(\d+)\h*;?}{use XML::Axk::L$1;}mg) {
        if($add_Ln) {
            $leader = "use XML::Axk::L1;\n";    # To be updated over time
        } else {
            croak "No version (Ln) specified in file $fn";
        }
    }

    # Mark the filename for the sake of error messages.
    #$fn =~ s{\\}{\\\\}g;   # This doesn't seem to be necessary based on
                            # the regex given for #line in perlsyn.
    $fn =~ s{"}{-}g;
        # as far as I can tell, #line can't handle embedded quotes.

    $leader .= ";\n#line 1 \"$fn\"\n";
        # Extra ; so the #line directive is in its own statement.
        # Thanks to https://www.effectiveperlprogramming.com/2011/06/set-the-line-number-and-filename-of-string-evals/

    # Put the user's script in its own package
    $leader = "package ". SCRIPT_PKG_PREFIX . "$scriptnumber {\n" .
        "use XML::Axk::Base;\n" .
        "use XML::Axk::Vars::Inject;\n" .
        'our $_AxkCore = $' . $self->global_name . ";\n" .
        "XML::Axk::Vars::Inject->inject(\$_AxkCore);\n" .
        $leader;
    $trailer .= "\n;};\n";
    ++$scriptnumber;

    $text = ($leader . $text . $trailer);

    if($self->{options}->{SHOW} && ref $self->{options}->{SHOW} eq 'ARRAY' &&
       any {$_ eq 'source'} @{$self->{options}->{SHOW}}) {
        say "****************Loading $fn:\n$text\n****************";
    }

    eval $text;
    croak "Could not parse '$fn': $@" if $@;
    #say "Done";
} #load_script_text

# }}}1
# Running =============================================================== {{{1

# Check for matches.  Superseded.
sub isTextMatch {   #static
    #say "isMatch: ", Dumper(\@_);
    my ($refPattern, $refLine) = @_;
    my $ty = ref $refPattern;

    if($ty eq 'Regexp') {
        return $$refLine =~ $refPattern;

    } elsif($ty eq 'SCALAR') {      # matches if the line contains the scalar
        return index($$refLine, $$refPattern) != -1;

    } else {    # todo check ::can('test')?
        return $refPattern->test($refLine);       # TODO expand this
    }
} #isMatch()

# Check for matches based on SAVs.
sub isMatch {
    #say "isMatch: ", Dumper(\@_);
    my ($self, $refPattern) = @_;
    my $sav = $self->{sav};
    my $ty = ref $refPattern;

    if($ty eq 'Regexp') {
        carp "Regexp not yet implemented";
        return false;

        #return false unless ref $sav->{E};
        #return $sav->{E} =~ $refPattern;    ## Note: not meaningful at the moment

    } elsif($ty eq 'SCALAR') {      # matches if the line contains the scalar
        carp "Scalar match not yet implemented";
        return false;

        #return false unless ref $sav->{E};
        #return index($$refLine, $$refPattern) != -1;

    } else {
        if(my $test = $refPattern->can("test")) {;
            return $refPattern->$test($sav);
        } else {
            carp "Pattern $refPattern doesn't implement test()";
            return false;
        }
    }
} #isMatch()

sub _run_pre_file {
    my ($self, $infn) = @_ or croak("Need a filename");

    foreach my $drAction (@{$self->{pre_file}}) {
        eval { &$drAction($infn) };   # which context are they evaluated in?
        croak "pre_file: $@" if $@;
    }
} # _run_pre_file

sub _run_post_file {
    my ($self, $infn) = @_ or croak("Need a filename");

    foreach my $drAction (@{$self->{post_file}}) {
        # TODO? make the last-seen node available to the action?
        # Similar to awk, in which the END block sees the last line as $0.
        eval { &$drAction($infn) };   # which context are they evaluated in?
        croak "post_file: $@" if $@;
    }
} # _run_post_file

# _run_worklist
sub _run_worklist {
    my $self = shift;
    my $now = shift;        # $now = HI, BYE, or CIAO

    my $sav = $self->{sav};
    my %new_savs = (@_);

    # TODO separate the internal variables for the doc and element from the
    # SAVs.  Move assignment of the SAVs into Ln.pm.

    # Assign the SAVs --------------

    # Clear to default.  TODO automate syncing the SAVs with XAV::Inject.
    $sav->{C} = "";
    @{$sav->{F}} = ();
    $sav->{D} = undef;
    $sav->{E} = undef;

    # Assign from params
    while (my ($key, $value) = each %new_savs) {
        unless(exists($sav->{$key})) {
            carp "Can't assign nonexistent sav $key";
            next;
        }

        if(ref $sav->{$key} eq 'ARRAY') {
            unless(ref $value eq 'ARRAY') {
                carp "Can't assign non-array to sav $key";
                next;
            }
            @{$sav->{$key}} = @$value;

        } elsif(ref $sav->{$key} eq 'HASH') {
            unless(ref $value eq 'HASH') {
                carp "Can't assign non-hash to sav $key";
                next;
            }
            %{$sav->{$key}} = %$value;

        } else {
            $sav->{$key}=$value;
        }
    }

    # Run the worklist -------------
    foreach my $lrItem (@{$self->{worklist}}) {
        #say Dumper($lrItem);
        my ($refPattern, $refAction, $when) = @$lrItem;
        #say "At time $now: running ", Dumper($lrItem);

        next if $when && ($now != $when);

        next unless $self->isMatch($refPattern);

        eval { &$refAction };   # which context are they evaluated in?
        croak "action: $@" if $@;
    } #foreach worklist item
} #_run_worklist

# Run the loaded script(s) against a single filehandle.
# TODO once I implement the different operating models (SAX, DOM, ?),
# make one run_text_fh function for each operating model.
sub run_text_fh {
    my ($self, $fh, $infn) = @_ or croak("Need a filehandle and filename");

    $self->_run_pre_file($infn);

    my $FNR = 0;    # TODO make this an SAV
    while(my $line = <$fh>) {
        say "\nLine ", ++$FNR, '==========================';
        #say "Got $line";

        # Send the SAV values to the user's scripts
        $self->{sav}->{C} = $line;
        @{$self->{sav}->{F}} = split ' ', $line;

        #say join ' ', 'main loop $C',\$self->{sav}->{C},
        #       '@F',\@{$self->{sav}->{F}};

        foreach my $lrItem (@{$self->{worklist}}) {
            my ($refPattern, $refAction, $when) = @$lrItem;

            next unless isTextMatch($refPattern, \$line);

            eval { &$refAction };   # which context are they evaluated in?
            croak "action: $@" if $@;
        } #foreach worklist item
    } # foreach line

    $self->_run_post_file($infn);
} #run_text_fh

sub run_sax_fh {
    my ($self, $fh, $infn) = @_ or croak("Need a filehandle and filename");
    my $runner;
    eval {
        use XML::Axk::SAX::Runner;
        $runner = XML::Axk::SAX::Runner->new($self);
    };
    die $@ if $@;

    $self->_run_pre_file($infn);
    $runner->run($fh, $infn);
    $self->_run_post_file($infn);

} #run_sax_fh()

# Run the loaded script(s).  Takes a list of inputs.  Strings are treated
# as filenames; references to strings are treated as raw data to be run
# as if read off disk.  A filename of '-' represents STDIN.  To process a
# disk file named '-', read its contents first and pass them in as a ref.
sub run {
    my $self = shift;

    #say "SPs:\n", Dumper(\%XML::Axk::Language::SP_Registry);

    foreach my $drAction (@{$self->{pre_all}}) {
        eval { &$drAction };   # which context are they evaluated in?
        croak "pre_all: $@" if $@;
    }

    foreach my $infn (@_) {
        my $fh;
        #say "Processing $infn";

        # Clear the SAVs before each file for consistency.
        $self->{sav}->{C} = undef;
        @{$self->{sav}->{F}} = ();

        # For now, just process lines rather than XML nodes.
        if($infn eq '-') {  # stdin
            open($fh, '<-') or croak "Can't open stdin!??!!";
        } else {            # disk file
            open($fh, "<", $infn) or croak "Can't open $infn: $!";
                # if $infn is a reference, its contents will be used -
                # http://www.perlmonks.org/?node_id=745018
        }

        #$self->run_text_fh($fh, $infn);
        $self->run_sax_fh($fh, $infn);

        close($fh) or warn "close failed: $!";

    } #foreach input filename

    foreach my $drAction (@{$self->{post_all}}) {
        # TODO? pass the last-seen node? (see note above)
        eval { &$drAction };   # which context are they evaluated in?
        croak "post_all: $@" if $@;
    }

} #run()

# }}}1
# Constructor and accessors ============================================= {{{1

sub _globalname {   # static int->str
    my $idx = shift;
    return "XML::Axk::Core::_I${idx}";
} #_globalname()

# For giving each instance of Core a unique package name (_globalname)
my $_instance_number = 0;

sub new {
    my $class = shift;
    my $hrOpts = shift // {};

    # Create the instance.
    my $data = {
        _id => ++$_instance_number,
        options => $hrOpts,

        # Load these in the order they are defined in the scripts.
        #our @pre_all = ();      # List of \& to run before reading the first file
        #our @pre_file = ();     # List of \& to run before reading each file
        #our @worklist = ();     # List of [$refCondition, \&action, $when]
        #                        # to be run against each node.
        #our @post_file = ();    # List of \& to run after reading each file
        #our @post_all = ();     # List of \& to run after reading the last file

        pre_all => [],
        pre_file => [],
        worklist => [],
        post_file => [],
        post_all => [],

        # Script-accessible vars
        sav => {
            C => undef,     # current line (old)
            F => [],        # current fields in that line (old)
            D => undef,     # current document
            E => undef      # current element
        },
        # NOTE: keys in sav are names without sigils.  I am not
        # sure whether this is more or less confusing than including the
        # sigils in the keys!  In any event, as a design decision, only one
        # sigil will be used for each name (i.e., no $foo and @foo).
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
# vi: set ts=4 sts=4 sw=4 et ai fo=cql foldmethod=marker foldlevel=0: #
