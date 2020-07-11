# Run this Perl script from any directory as: .../dosmc examples/tool

my $a = join(", ", @ARGV);
print "0=$0\n";
print "ARGV=($a)\n";
print "PATH=($ENV{PATH})\n";
print "INC=@INC\n";
# Existing Perl function in dosmc can be used.
die "missing fix_path\n" if !defined(*main::fix_path);
print "tool OK.\n";
42
