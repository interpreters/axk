# XML::Axk::Base: common definitions for axk.
# Thanks to David Farrell,
# https://www.perl.com/article/how-to-build-a-base-module/

package XML::Axk::Base;

# Pragmas
use feature ":5.18";
use strict;
use warnings;
use constant {true => !!1, false => !!0};

# Packages
use Data::Dumper;

say 'XML::Axk::Base running';

sub import {
    say 'XML::Axk::Base->import() running';
    feature->import(':5.18');
    strict->import;
    warnings->import;

    # Copy symbols.
    my $caller = caller(0);     # get the importing package name

    do {
        no strict 'refs';
        *{"$caller\:\:true"}  = *{"true"};
        *{"$caller\:\:false"}  = *{"false"};

        *{"$caller\:\:Dumper"}  = *{"Data\:\:Dumper\:\:Dumper"};
    };
} #import()

1;

# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
