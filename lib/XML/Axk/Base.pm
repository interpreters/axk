# XML::Axk::Base: common definitions for axk.
# Thanks to David Farrell,
# https://www.perl.com/article/how-to-build-a-base-module/

package XML::Axk::Base;
use parent 'Exporter';
use Import::Into;

# Pragmas
use feature ":5.18";
use strict;
use warnings;

# Packages
use Data::Dumper;
use Carp;

# Definitions from this file
use constant {true => !!1, false => !!0};
our @EXPORT = qw(true false);

BEGIN {
    $SIG{'__DIE__'} = sub { Carp::confess(@_) } if not $SIG{'__DIE__'};
}

sub import {

    # Copy symbols listed in @EXPORT first, in case @_ gets trashed later
    shift->export_to_level(1, @_);

    my $target = caller;

    # Re-export pragmas
    feature->import::into($target, qw(:5.18));
    foreach my $pragma (qw(strict warnings)) {
        ${pragma}->import::into($target);
    };

    # Re-export packages
    Data::Dumper->import::into($target);
    Carp->import::into($target, qw(carp croak confess));

} #import()

#    # Example of manually copying symbols, for reference
#    # Copy symbols.
#    my $caller = caller(0);     # get the importing package name
#    do {
#        no strict 'refs';
#        *{"${caller}::true"}  = *{"true"};
#    };

1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
