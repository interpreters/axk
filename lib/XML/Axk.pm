#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.
# XML::Axk: Stub package that chains to XML::Axk::Core.

package XML::Axk;
use XML::Axk::Base;
use XML::Axk::Core;
use XML::Axk::App;
use Import::Into;

our $VERSION;
$VERSION = '0.01';

sub import {
    XML::Axk::Core->import::into(1);
    XML::Axk::App->import::into(1);
}

1;
__END__
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk - ack-like XML processor

=head1 VERSION

Version 0.01

=head1 USAGE

    use XML::Axk;

    # Canned interface, as if run from the command line
    XML::Axk::App::Main(\@ARGV)

    # Perl interface
    my $axk = XML::Axk::Core->new();

For details about the command-line interface, see C<perldoc XML::Axk::App>.

=head1 OPTIONS

None yet!

A filename of C<-> represents standard input.  To actually process a file
named C<->, you will need to use shell redirection (e.g., C<< axk < - >>).

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=head2 function2

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

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2018 Christopher White.  All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). Details are in the LICENSE
file accompanying this distribution.

=cut

# }}}1
# vi: set ts=4 sts=4 sw=4 et ai fo=cql foldmethod=marker foldlevel=0: #
