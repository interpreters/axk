# Tests for XML::Axk::L1.
# Copyright (c) 2018 cxw42.  All rights reserved.  Artistic 2.
package T::XML::Axk::L1;

use AxkTest;
use parent 'Test::Class';

sub class { "XML::Axk::L1" };

diag("Testing ", class);

# Inline script, operation at runtime ============================= {{{1
sub t1 :Test(1) {
    my $core = XML::Axk::Core->new();
    $core->load_script_text(q{
        L1
        perform { say $E; } xpath("//item");
        perform { say $E; } xpath(q<//@attrname>);
    });
    # Note: q<> is because Perl tries to interpolate an array into "//@attrname"

    my $out = capture_stdout { $core->run(tpath 'ex/ex1.xml'); };
    like($out, qr<(XML::DOM::Element[^\n]*\n){2}>, 'matched multiple elements');
}

# }}}1

1;

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=1: #
