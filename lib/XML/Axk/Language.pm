# XML::Axk::Language - common definitions for axk language modules (X::A::Ln).

package XML::Axk::Language;
use XML::Axk::Base ':all';
use Import::Into;
use vars;

use XML::Axk::Vars::Scalar;
use XML::Axk::Vars::Array;

#use Devel::StackTrace;

# Registry mapping XALn package names to arrayrefs of the script parameters
# (SPs) for those packages.
#our %SP_Registry = ();

# Variable injection ============================================= {{{2

# Regular function (not a class or instance method).
# Sets up the tie between an SP in the script and its storage in the core.
sub _inject_var {
    my ($core, $target, $lang, $varname) = @_;
    my $basename = substr($varname, 1);
    no strict 'refs';

    if(substr($varname, 0, 1) eq '$') {         # scalar
        tie(${"${target}::${basename}"}, 'XML::Axk::Vars::Scalar',
            $core, $lang, $varname);

    } elsif(substr($varname, 0, 1) eq '@') {    # array
        tie(@{"${target}::${basename}"}, 'XML::Axk::Vars::Array',
            $core, $lang, $varname);

    } else {
        croak "Can't inject unknown var type $varname";
    }
} #_inject_var()

# }}}2
# Export ========================================================= {{{1
sub import {
    my $lang = caller;
    my $class = shift;
    if($class ne __PACKAGE__) {     # do I need this?
        confess(__PACKAGE__ . " initializer called from class $class");
    }

    #say "XALanguage run from $target:\n", Devel::StackTrace->new->as_string;

    # Set up the registry
    #$SP_Registry{$lang} = [] unless exists $SP_Registry{$lang};
    #my $lrRegistry = $SP_Registry{$lang};

    my %opts = ( $#_>0 && $#_ ? @_ : () );  # even number of args => options
    my @sps;

    # sp: populate the registry with the given variables.
    if(exists $opts{sp} && $opts{sp}) {
        croak "Need an arrayref for the SPs" unless ref $opts{sp} eq 'ARRAY';
        @sps = @{$opts{sp}};
    } #`sp` option

    my $core;   # _AxkCore in the target, if any

    # target: mark the given axk_script (if any)
    if(exists $opts{target} && $opts{target}) {

        my $script = $opts{target};
        my $varname = "${script}::_AxkLang";
        my $corename = "${script}::_AxkCore";

        #say "Loading $varname with $lang";
        do {
            no strict 'refs';
            croak "A script can only use one language" if defined $$varname;
            vars->import::into($script, '$' . ($varname =~ s/^.*:://r));
            $$varname = $lang;

            $core = $$corename if defined $$corename;
        };

        # Inject the script parameters
        if(@sps) {
            vars->import::into($script, @sps);

            if($core) {     # Link the SPs in $script to storage in $core
                $core->allocate_sps($lang, @sps);
                _inject_var($core, $script, $lang, $_) for @sps;
            }
        }

    } #`target` option

} #import()

# }}}1
1;
# === Documentation ===================================================== {{{2

=pod

=encoding UTF-8

=head1 NAME

XML::Axk::Language - base language code for the axk XML processor

=head1 VERSION

Version 0.01

=head1 USAGE

When implementing a language:

    require XML::Axk::Language;
    sub import {
        XML::Axk::Language->import( target => caller, sp => [qw($foo @bar)] );
    }

The C<target> option is the package to load into, and the C<sp> option is
the list of script parameters to load.

If all you need is the registry:

    use XML::Axk::Language ();
    # Then do something with @XML::Axk::Language::SP_Registry.

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

# }}}2
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=1: #
