#!perl
# 04-languages.t: Multi-language support

use 5.018;
use strict;
use warnings;
use Test::More; # tests=>27;
use Capture::Tiny 'capture_stdout';
use File::Spec;
use XML::Axk::App;

sub localpath {
    state $voldir = [File::Spec->splitpath(__FILE__)];
    return File::Spec->catpath($voldir->[0], $voldir->[1], shift)
}

# Inline script =================================================== {{{1
{
    my $out = capture_stdout
        { XML::Axk::App::Main(['--no-input', '-e',
            "say __LINE__;\nL1\nL0\nL1\nL0\nL0\nL1\nL1\nsay __LINE__;" ])
        };
   like($out, qr/1\n9\n\Z/, 'line number counting works');
}

# }}}1

done_testing();

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
