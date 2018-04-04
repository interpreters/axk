package XML::Axk::App;
use XML::Axk::Base;
use XML::Axk::Core;

our $VERSION = '0.01';

use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt);

#use Web::Query::LibXML;

use constant DEBUG			=> false;

# Shell exit codes
use constant EXIT_OK 		=> 0;	# success
use constant EXIT_PROC_ERR 	=> 1;	# error during processing
use constant EXIT_PARAM_ERR	=> 2;	# couldn't understand the command line

# === Command line parsing ============================================== {{{1

# files/scripts to load, in order.
# Each element is [isfile, text].
my @Sources;

my $dr_save_source = sub {
    my ($which, $text) = @_;
    push @Sources, [$which eq 'f', $text];
}; # dr_save_source

my %CMDLINE_OPTS = (
    # hash from internal name to array reference of
    # [getopt-name, getopt-options, optional default-value]
    #   --- However, if default-value is a reference, it will be the
    #   --- destination for that value.
    # They are listed in alphabetical order by option name,
    # lowercase before upper, although the code does not require that order.

    #DUMP_VARS => ['d', '|dump-variables', false],
    #DEBUG => ['D','|debug', false],
    EVAL => ['e','|source=s@', $dr_save_source],
    #RESTRICTED_EVAL => ['E','|exec=s@'],
    SCRIPT => ['f','|file=s@', $dr_save_source],
    # -F field separator?
    # -h and --help reserved
    # INPUT_FILENAME assigned by parse_command_line_into()
    #INCLUDE => ['i','|include=s@'],
    #KEEP_GOING => ['k','|keep-going',false], #not in gawk
    #LIB => ['l','|load=s@'],
    #LINT => ['L','|lint:s'],
    # --man reserved
    # OUTPUT_FILENAME => ['o','|output=s', ""], # conflict with gawk
    #SANDBOX => ['S','|sandbox',false],
    # --usage reserved
    PRINT_VERSION => ['V','|version', false],
    DEFS => ['v','|var:s%'],
    # -? reserved

    # Long-only options that are specific to axk.
    SHOW => ['show',':s@'],     # which debugging output to print.
                                # TODO make it a hash instead?
);

sub parse_command_line {
    # Takes {into=>hash ref, from=>array ref}.  Fills in the hash with the
    # values from the command line, keyed by the keys in %CMDLINE_OPTS.

    my %params = @_;
    #croak "Missing arg from" unless $params{from};
    #croak "Missing arg into" unless $params{into};

    my $hrOptsOut = $params{into};

    # Easier syntax for checking whether optional args were provided.
    # Syntax thanks to http://www.perlmonks.org/?node_id=696592
    local *have = sub { return exists($hrOptsOut->{ $_[0] }); };

    # Set defaults so we don't have to test them with exists().
    %$hrOptsOut = (     # map getopt option name to default value
        map { $CMDLINE_OPTS{ $_ }->[0] => $CMDLINE_OPTS{ $_ }[2] }
        grep { (scalar @{$CMDLINE_OPTS{ $_ }})==3 }
        keys %CMDLINE_OPTS
    );

    # Get options
    my $opts_ok = GetOptionsFromArray(
        $params{from},                  # source array
        $hrOptsOut,                     # destination hash
        'usage|?', 'h|help', 'man',     # options we handle here
        map { $_->[0] . $_->[1] } values %CMDLINE_OPTS,     # options strs
        );

    # Help, if requested
    if(!$opts_ok || have('usage') || have('h') || have('man')) {
        # Only pull in the Pod routines if we actually need them.
        require Pod::Usage;

        #require Pod::Find; # qw(pod_where);
        #my $pod_input = Pod::Find::pod_where({-inc => 1, -verbose=>1}, __PACKAGE__);
            # This takes a long time on my system.

        Pod::Usage::pod2usage(-verbose => 0, -exitval => EXIT_PARAM_ERR, -input => __FILE__) if !$opts_ok;    # unknown opt
        Pod::Usage::pod2usage(-verbose => 0, -exitval => EXIT_OK, -input => __FILE__) if have('usage');
        Pod::Usage::pod2usage(-verbose => 1, -exitval => EXIT_OK, -input => __FILE__) if have('h');
        Pod::Usage::pod2usage(-verbose => 2, -exitval => EXIT_OK, -input => __FILE__) if have('man');
    }

    # Map the option names from GetOptions back to the internal names we use,
    # e.g., $hrOptsOut->{EVAL} from $hrOptsOut->{e}.
    my %revmap = map { $CMDLINE_OPTS{$_}->[0] => $_ } keys %CMDLINE_OPTS;
    for my $optname (keys %$hrOptsOut) {
        $hrOptsOut->{ $revmap{$optname} } = $hrOptsOut->{ $optname };
    }

    # Process other arguments.  TODO? support multiple input filenames?
    #$hrOptsOut->{INPUT_FILENAME} = $ARGV[0] // "";

} #parse_command_line()

# }}}1
# === Command-line runner =============================================== {{{1

# Command-line runner.  Call as XML::Axk::App::Main(\@ARGV).
sub Main {
    my $lrArgs = shift;

    my %opts;
    parse_command_line(from => $lrArgs, into => \%opts);

    # Treat the first non-option arg as a script if appropriate
    unless(@Sources) {
        croak "No scripts to run" unless @$lrArgs;
        push @Sources, [false, shift @$lrArgs];
    }

    my $core = XML::Axk::Core->new(\%opts);
        # Note: core doesn't copy the provided options, so make sure
        # they stick around as long as $core does.

    my $cmd_line_idx = 0;   # Number the `-e`s on the command line
    foreach my $lrSource (@Sources) {
        my ($is_file, $text) = @$lrSource;
        if($is_file) {
            $core->load_script_file($text);
        } else {
            $core->load_script_text($text,
                "(cmd line script #@{[++$cmd_line_idx]})",
                true);  # true => add a Vn if there isn't one in the script
        }
    } #foreach source

    # read from stdin if no input files specified.
    push @$lrArgs, '-' unless @$lrArgs;

    $core->run(@$lrArgs);

    return 0;
} #Main()

# }}}1

# no import() --- call Main() directly with its fully-qualified name

1; # End of XML::Axk::App
__END__
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk::App - ack-like XML processor, command-line interface

=head1 VERSION

Version 0.01

=head1 USAGE

    axk [options] [--] [script or input filename]

=head1 OPTIONS

A filename of C<-> represents standard input.  To actually process a file
named C<->, you will need to use shell redirection (e.g., C<< axk < - >>).

The first non-option argument is a program if no -e or -f are given.
The script language version for a -e will default to the latest if the text
on the command line doesn't match C</^\s*V\s*\d+[\s;]+/>.

=head1 AUTHOR

Christopher White, C<< <cxwembedded at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-axk at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Axk>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::Axk

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-Axk>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-Axk>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-Axk>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-Axk/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Christopher White.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

# }}}1
# vi: set ts=4 sts=4 sw=4 et ai foldmethod=marker: #
