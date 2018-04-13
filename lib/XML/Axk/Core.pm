#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.

# Style note: Hungarian prefixes are used on scalars:
#   "hr" (hash ref), "lr" (list ref), "sr" (string ref), "nr" (numeric ref),
#   "dr" ("do," i.e., block ref), "ref" (unspecified ref),
#   "b" or "is" (boolean), "s" (string)

package XML::Axk::Core;
use XML::Axk::Base qw(:all);

# Wrapper around string eval, way up here so it can't see any of the
# lexicals below.
sub eval_nolex {
    eval shift;
    return $@;
} #eval_nolex

use XML::Axk::Language ();
use XML::Axk::Sandbox;

use version 0.77; our $VERSION = version->declare("v0.1.0");

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

An axk script can include a C<Ln> pragma that specifies the axk
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

    # Put the user's script in its own package, with its own sandbox
    ++$scriptnumber;
    my $scriptname = SCRIPT_PKG_PREFIX . $scriptnumber;
    my $sandbox = XML::Axk::Sandbox->new($self, $scriptname);

    { # preload the sandbox into the script's package
        no strict 'refs';
        ${"${scriptname}::_AxkSandbox"} = $sandbox;
    }

    $leader = "package $scriptname {\n" .
        "use XML::Axk::Base;\n" .
        $leader;
    $trailer .= "\n;};\n";

    $text = ($leader . $text . $trailer);

    if($self->{options}->{SHOW} && ref $self->{options}->{SHOW} eq 'ARRAY' &&
       any {$_ eq 'source'} @{$self->{options}->{SHOW}}) {
        say "****************Loading $fn:\n$text\n****************";
    }

    my $at = eval_nolex $text;
    croak "Could not parse '$fn': $at" if $at;
} #load_script_text

# }}}1
# Running =============================================================== {{{1

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

    my %CPs = (@_);         # Core parameters

    # Assign the SPs from the CPs --

    while (my ($lang, $drUpdater) = each %{$self->{updaters}}) {
        $drUpdater->($self->{sp}->{$lang}, %CPs);
    }

    # Run the worklist -------------

    foreach my $lrItem (@{$self->{worklist}}) {
        #say Dumper($lrItem);
        my ($refPattern, $refAction, $when) = @$lrItem;
        #say "At time $now: running ", Dumper($lrItem);

        next if $when && ($now != $when);

        next unless $refPattern->test(\%CPs);
            # Matchers use CPs so they are independent of language.

        eval { &$refAction };   # which context are they evaluated in?
        croak "action: $@" if $@;
    } #foreach worklist item
} #_run_worklist

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

        # Clear the SPs before each file for consistency.
        $self->{sp}->{'$C'} = undef;
        @{$self->{sp}->{'@F'}} = ();

        # For now, just process lines rather than XML nodes.
        if($infn eq '-') {  # stdin
            open($fh, '<-') or croak "Can't open stdin!??!!";
        } else {            # disk file
            open($fh, "<", $infn) or croak "Can't open $infn: $!";
                # if $infn is a reference, its contents will be used -
                # http://www.perlmonks.org/?node_id=745018
        }

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
        #our @pre_all = ();
        #our @pre_file = ();
        #our @worklist = ();
        #
        #our @post_file = ();
        #our @post_all = ();

        pre_all => [],      # List of \& to run before reading the first file
        pre_file => [],     # List of \& to run before reading each file
        worklist => [],     # List of [$refCondition, \&action, $when] to be run against each node.
        post_file => [],    # List of \& to run after reading each file
        post_all => [],     # List of \& to run after reading the last file

        # Script parameters, indexed by language name (X::A::Ln).
        # Format: { lang name => { varname with sigil => value, ... }, ... }
        sp => {},

        # Per-language updaters, indexed by language name
        updaters => {},

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

# Allocate the SPs for a particular language.
# All the SPs must be given in one call.  Subsequent calls are nops.
sub allocate_sps {
    my $self = shift;
    my $lang = shift;
    return if exists $self->{sp}->{$lang};
    my $hr = $self->{sp}->{$lang} = {};

    for my $name (@_) {
        my $sigil = substr($name, 0, 1);
        $self->{sp}->{$lang}->{$name} = undef, next if $sigil eq '$';
        $self->{sp}->{$lang}->{$name} = [], next if $sigil eq '@';
    }

    #say Dumper \%{$self->{sp}};
} #allocate_sp()

sub set_updater {
    my $self = shift;
    my $lang = shift;
    return if exists $self->{updaters}->{$lang};
    $self->{updaters}->{$lang} = shift // sub {};
} #set_updater()

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
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk::Core - ack-like XML processor, core

=head1 VERSION

Version 0.1.0

=head1 USAGE

    my $core = XML::Axk::Core->new(\%opts);
    $core->load_script_file($filename);
    $core->load_script_text($source_text, $filename);
    $core->run(@input_filenames);

=head1 OPTIONS

A filename of C<-> represents standard input.

=head1 SUBROUTINES

=head2 XML::Axk::Core->new

Constructor.  Takes a hash ref of options

=head1 METHODS

=head2 load_script_file

=head2 load_script_text

=head2 run

=head1 AUTHOR

Christopher White, C<cxwembedded at gmail.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-axk at rt.cpan.org>, or
through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Axk>.  I will be notified,
and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::Axk::Core

You can also look for information at:

=over 4

=item * GitHub: The project's main repository and issue tracker

L<https://github.com/cxw42/axk>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-Axk>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-Axk>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-Axk>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-Axk/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2018 Christopher White.  All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). Details are in the LICENSE
file accompanying this distribution.

=cut

# }}}1
# vi: set ts=4 sts=4 sw=4 et ai fo=cql foldmethod=marker foldlevel=0: #
