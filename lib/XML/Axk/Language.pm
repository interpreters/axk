# XML::Axk::Language - common definitions for axk language modules (X::A::Ln).

package XML::Axk::Language;
use XML::Axk::Base ':all';
use Import::Into;
use vars;

# Registry mapping XALn package names to arrayrefs of the script parameters
# (SPs) for those packages.
our %SP_Registry = ();

# Find the axk_script_n package above us in the tree, if any.
sub find_axk_script_package {
    my $level = 0;
    my $pkg;
    my $re = '^' . SCRIPT_PKG_PREFIX . '\d';
    $re = qr/$re/;

    while(defined($pkg = caller($level))) {
        return $pkg if $pkg =~ $re;
        ++$level;
    }

    return undef;
} #find_axk_script_package()

sub import {
    my $target = caller;
    my $class = shift;
    return if $class ne __PACKAGE__;

    # Set up the registry
    $SP_Registry{$target} = {} unless exists $SP_Registry{$target};

    return unless $#_>0 && $#_;     # even number of args => options
    my %opts = @_;

    my $script = find_axk_script_package;   # if any

    # L: mark the calling axk_script (if any)
    if(exists $opts{L} && defined $script) {
        my $varname = "${script}::_AxkLang";
        do {
            no strict 'refs';
            croak "Can't declare two languages in a script" if defined ${$varname};
        };

        vars->import::into($script, '$_AxkLang');

        do {
            no strict 'refs';
            ${$varname} = 0 + $opts{L};    # always numeric
        };
    } #option L

} #import()

1;
# === Documentation ===================================================== {{{1

=pod

=encoding UTF-8

=head1 NAME

XML::Axk::Language - base language code for the axk XML processor

=head1 VERSION

Version 0.01

=head1 USAGE

When implementing a language:

   use XML::Axk::Language L=>123;

where C<123> is the language number.

If all you need is the registry:

   use XML::Axk::Language;

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
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
