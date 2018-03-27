# XML::Axk::Base: common definitions for axk.
# Thanks to David Farrell,
# https://www.perl.com/article/how-to-build-a-base-module/

package XML::Axk::Base;
use parent 'Exporter';

# Pragmas
use feature ":5.18";
use strict;
use warnings;

# Packages
use Data::Dumper;
use Carp qw(carp croak confess);

# Definitions from this file
use constant {true => !!1, false => !!0};

our @EXPORT = qw(true false Dumper);

say 'XML::Axk::Base running';

BEGIN {
    $SIG{'__DIE__'} = sub { confess(@_) } if not $SIG{'__DIE__'};
}

sub import {

    # Copy symbols listed in @EXPORT first, in case @_ gets trashed later
    XML::Axk::Base->export_to_level(1, @_);

    # Re-export pragmas
    feature->import(':5.18');
    strict->import;
    warnings->import;

    # Re-export packages
    #Data::Dumper->import;  # not sure why this doesn't work, but it doesn't.
                            # I listed it in @EXPORT above.
    Carp->import(qw(carp croak confess));

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
