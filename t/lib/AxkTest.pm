#!perl
# AxkTest.pm: Test::Kit for XML::Axk

use Test::Kit;
use 5.018;
use strict;
use warnings;

include feature => {
    import => [':5.18']
};
include qw(strict warnings);
include qw(Test::More File::Spec XML::Axk::App);
include 'Capture::Tiny' => {
    import => [qw(capture_stdout capture_merged)]
};

1;

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
