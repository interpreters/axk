#!perl

use 5.018;
use strict;
use warnings;
use Test::More;

ok(1,"Not here yet!");

done_testing();
__END__

./run -e 'perform { say $E; } xpath("//item"); perform { say $E; } xpath(q<//@attrname>);' ex/ex1.xml
  # Because Perl tries to interpolate an array into "//@attrname"

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
