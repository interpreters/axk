#!perl

use 5.018;
use strict;
use warnings;
use Test::More;
use Capture::Tiny 'capture_stdout';
use XML::Axk::Core;

sub localpath {
    state $voldir = [File::Spec->splitpath(__FILE__)];
    return File::Spec->catpath($voldir->[0], $voldir->[1], shift)
}

# Inline script, operation at runtime ============================= {{{1
{
    my $core = XML::Axk::Core->new();
    $core->load_script_text(q{
        L1
        perform { say $E; } xpath("//item");
        perform { say $E; } xpath(q<//@attrname>);
    });
    # Note: q<> is because Perl tries to interpolate an array into "//@attrname"

    my $out = capture_stdout { $core->run(localpath 'ex/ex1.xml'); };
    like($out, qr<(XML::DOM::Element[^\n]*\n){2}>, 'matched multiple elements');
}

# }}}1

done_testing();
__END__


# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
