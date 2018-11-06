#!/usr/bin/env perl
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.
# XML::Axk: Stub package that just holds the version

package XML::Axk;
use XML::Axk::Base;     # uses 5.018, so we can safely use v-strings.

use version 0.77; our $VERSION = version->declare("v0.1_2");
    # underscore before last component => alpha version

1;
__END__
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk - ack-like XML processor

=head1 USAGE

    use XML::Axk::App;      # pick whichever you want,
    use XML::Axk::Core;     # or both

    # Canned interface, as if run from the command line
    XML::Axk::App::Main(\@ARGV)

    # Perl interface
    my $axk = XML::Axk::Core->new();

For details about the command-line interface, see L<XML::Axk::App>.

For details about the library interface, see L<XML::Axk::Core>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::Axk::App
    perldoc XML::Axk::Core

You can also look for information on the GitHub project page at
L<https://github.com/interpreters/axk>.

=head1 AUTHOR

Christopher White, C<cxwembedded at gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2018 Christopher White.  All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). Details are in the LICENSE
file accompanying this distribution.

=cut

# }}}1
# vi: set ts=4 sts=4 sw=4 et ai fo=cql foldmethod=marker foldlevel=0: #
