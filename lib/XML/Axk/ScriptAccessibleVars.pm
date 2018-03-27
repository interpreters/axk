#!/usr/bin/env perl
# XML::Axk::ScriptAccessibleVars: variables accessible from axk scripts.
# Copyright (c) 2018 cxw42.  All rights reserved.  CC-BY-SA 3.0.

package XML::Axk::ScriptAccessibleVars;
use XML::Axk::Base;

# Variables ====================================================== {{{1
# Note: `our` variables are shared between all running scripts.
our $foo = 'Hello, world!  from ScriptAccessibleVars';

# }}}1
# Export ========================================================= {{{1
use parent 'Exporter';
our @EXPORT = qw($foo);

# }}}1
1;
# vi: set ts=4 sts=4 sw=4 et ai fo-=ro foldmethod=marker foldlevel=1: #
