#
# dosmclib/dosmc.pl: build script for dosmc.lib libc (C runtime library)
# by pts@fazekas.hu at Mon May 23 01:27:25 CEST 2022
#
# Usage: ./dosmc dosmclib
# Output file: dosmc.dir/dosmc.lib
#

BEGIN { $^W = 1 }
use integer; use strict;
my $dir = $INC[0];
my $d;
die "$0: fatal: opendir: $dir: $!\n" if !opendir($d, $dir);
my @sources = map { "$dir/$_" } grep { m@[.]wasm\Z(?!\n)@ } readdir($d);
die "$0: fatal: closedir: $dir: $!\n" if !closedir($d);
dosmc("-nq", "-cl", "-fo=$dir/../dosmc.dir/dosmc.lib", @sources);
dosmc("-nq", "-cldl");  # Check that the internal linker can load dosmc.lib.

