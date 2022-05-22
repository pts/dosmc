print "DIR 0=$0\n";
my $tool_result = main::run_perl_script("tool.pl", @ARGV);  # Still doesn't work.
print "TOOL result=$tool_result\n";
