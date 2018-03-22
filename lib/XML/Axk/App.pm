package XML::Axk::App;
use XML::Axk::Base;
use XML::Axk::Core;

use Getopt::Long qw(GetOptionsFromArray);
use Pod::Usage;
use Pod::Find qw(pod_where);

use Web::Query::LibXML;

use constant DEBUG			=> false;

# Shell exit codes
use constant EXIT_OK 		=> 0;	# success
use constant EXIT_PROC_ERR 	=> 1;	# error during processing
use constant EXIT_PARAM_ERR	=> 2;	# couldn't understand the command line

our $VERSION = '0.01';

say "XML::Axk::App running";

# === Command line parsing ============================================== {{{1

my %CMDLINE_OPTS = (
    # hash from internal name to array reference of
    # [getopt-name, getopt-options, optional default-value]
    # They are listed in alphabetical order by option name,
    # lowercase before upper, although the code does not require that order.

    DEBUG => ['d','|E|debug', false],
    DEFS => ['D','|define:s%'],     # In %D, and text substitution
    EVAL => ['e','|eval=s', ''],
    # -h and --help reserved
    # INPUT_FILENAME assigned by parse_command_line_into()
    KEEP_GOING => ['k','|keep-going',false],
    # --man reserved
    OUTPUT_FILENAME => ['o','|output=s', ""],
    SETS => ['s','|set:s%'],        # Extra data in %S, without text substitution
    # --usage reserved
    PRINT_VERSION => ['v','|version'],
    # -? reserved
);

sub parse_command_line {
    # Takes {into=>hash ref, from=>array ref}.  Fills in the hash with the
    # values from the command line, keyed by the keys in %CMDLINE_OPTS.

    my %params = @_;
    croak "Missing arg from" unless $params{from};
    croak "Missing arg into" unless $params{into};

    my $hrOptsOut = $params{into};

    # Easier syntax for checking whether optional args were provided.
    # Syntax thanks to http://www.perlmonks.org/?node_id=696592
    local *have = sub { return exists($hrOptsOut->{ $_[0] }); };

    Getopt::Long::Configure 'gnu_getopt';

    # Set defaults so we don't have to test them with exists().
    %$hrOptsOut = (     # map getopt option name to default value
        map { $CMDLINE_OPTS{ $_ }->[0] => $CMDLINE_OPTS{ $_ }[2] }
        grep { (scalar @{$CMDLINE_OPTS{ $_ }})==3 }
        keys %CMDLINE_OPTS
    );

    # Get options
    GetOptionsFromArray(
        $params{from},                  # source array
        $hrOptsOut,                     # destination hash
        'usage|?', 'h|help', 'man',     # options we handle here
        map { $_->[0] . $_->[1] } values %CMDLINE_OPTS,     # options strs
        )
    or pod2usage(-verbose => 0, -exitval => EXIT_PARAM_ERR);    # unknown opt

    # Help, if requested
    my $pod_input = pod_where({-inc => 1}, __PACKAGE__);
    pod2usage(-verbose => 0, -exitval => EXIT_PROC_ERR, -input => $pod_input) if have('usage');
    pod2usage(-verbose => 1, -exitval => EXIT_PROC_ERR, -input => $pod_input) if have('h');
    pod2usage(-verbose => 2, -exitval => EXIT_PROC_ERR, -input => $pod_input) if have('man');

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

# Command-line runner.  Call as XML::Axk::App::run(\@ARGV).
sub Main {
    my $lrArgs = shift;
    say 'Args:' . Dumper($lrArgs);

    my %opts;
    parse_command_line(from => $lrArgs, into => \%opts);

    say "Opts: " . Dumper(\%opts);
    say "Remaining: " . Dumper($lrArgs);

    # TODO only load scripts
    say "Loading scripts";
    foreach my $filename (@{$lrArgs}) {
        XML::Axk::Core::load_script($filename);
    }

    say "Running";
    XML::Axk::Core::run();
    say "App:main done";

    return 0;
} #Main()

1; # End of XML::Axk::App

__END__
# }}}1
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk::App - The great new XML::Axk!

=head1 VERSION

Version 0.01

=head1 USAGE

    use XML::Axk::App;
    XML::Axk::App::Main(\@ARGV)

    use XML::Axk;
    my $foo = XML::Axk->new();

=head1 OPTIONS

None yet!

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=head2 function2

=cut

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
