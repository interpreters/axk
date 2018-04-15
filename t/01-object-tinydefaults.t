#!perl -T

package main;

use 5.018;
use strict;
use warnings;
use Test::More tests=>27;

BEGIN {
    use_ok( 'Object::TinyDefaults' ) || print "Bail out!\n";
}

diag( "Testing Object::TinyDefaults $Object::TinyDefaults::VERSION, Perl $], $^X" );

# No defaults ===================================================== {{{1
package NoDefaults {
    use Object::TinyDefaults qw(foo bar);
}

package main {
    my $x = NoDefaults->new();
    isa_ok($x, 'NoDefaults');
    isa_ok($x, 'Object::TinyDefaults');
    ok(!$x->foo, 'No default => falsy (foo)');
    ok(!$x->bar, 'No default => falsy (bar)');
    $x->{foo} = 42;
    $x->{bar} = 'yes';
    is($x->foo, 42, 'numeric assignment');
    is($x->bar, 'yes', 'string assignment');
}

# }}}1
# Defaults and field names ======================================== {{{1
package DefaultsAndNames {
    use Object::TinyDefaults { foo => 'default' }, qw(foo bar);
}

package main {
    my $x = DefaultsAndNames->new();
    isa_ok($x, 'DefaultsAndNames');
    isa_ok($x, 'Object::TinyDefaults');
    is($x->foo, 'default', 'default (foo)');
    ok(!$x->bar, 'no default => falsy (bar)');
    $x->{foo} = 42;
    $x->{bar} = 'yes';
    is($x->foo, 42, 'numeric assignment');
    is($x->bar, 'yes', 'string assignment');
}

# }}}1
# Defaults and field names; some names only in defaults =========== {{{1
package DefaultsWithNamesAndNames {
    use Object::TinyDefaults { quux => 'default' }, qw(foo bar);
}

package main {
    my $x = DefaultsWithNamesAndNames->new();
    isa_ok($x, 'DefaultsWithNamesAndNames');
    isa_ok($x, 'Object::TinyDefaults');
    is($x->quux, 'default', 'default (quux)');
    ok(!$x->foo, 'no default => falsy (foo)');
    ok(!$x->bar, 'no default => falsy (bar)');
    $x->{quux} = [];
    $x->{foo} = 42;
    $x->{bar} = 'yes';
    is(ref $x->{quux}, 'ARRAY', 'arrayref assignment');
    is($x->foo, 42, 'numeric assignment');
    is($x->bar, 'yes', 'string assignment');
}

# }}}1
# Defaults only =================================================== {{{1
package DefaultsOnly {
    use Object::TinyDefaults { quux => 'default', foo=>42 };
}

package main {
    my $x = DefaultsOnly->new();
    isa_ok($x, 'DefaultsOnly');
    isa_ok($x, 'Object::TinyDefaults');
    is($x->quux, 'default', 'default (quux)');
    is($x->foo, 42, 'default (foo)');
    $x->{quux} = 'yes';
    $x->{foo} = 'indeed';
    is($x->quux, 'yes', 'string assignment (quux)');
    is($x->foo, 'indeed', 'string assignment (foo)');
}

# }}}1

#done_testing();

# vi: set ts=4 sts=4 sw=4 et ai fdm=marker fdl=0: #
