# axk::base: common definitions for axk.
# Thanks to David Farrell,
# https://www.perl.com/article/how-to-build-a-base-module/
package axk::base;

use v5.18;
use strict;
use warnings;
use constant {true => !!1, false => !!0};
use Data::Dumper;

sub import {
    feature->import(':5.18');
    strict->import;
    warnings->import;

    # Copy symbols.
    my $caller = caller(0);     # get the importing package name

    do {
        no strict 'refs';
        *{"$caller\:\:Dumper"}  = *{"Data\:\:Dumper\:\:Dumper"};
        *{"$caller\:\:true"}  = *{"true"};
        *{"$caller\:\:false"}  = *{"false"};
    };
1;

#}}}1

# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker ft=perl: #
