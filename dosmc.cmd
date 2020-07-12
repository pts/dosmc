@set m=%~dpn0.cmd
@for %%f in ("%~n0.cmd") do if not exist "%~dpn0.cmd" set m=%%~dpn$PATH:f.cmd
@if "%m%"==".cmd" echo fatal: program not found: %~n0.cmd 1>&2 & exit /b 1
@for %%f in ("%m%") do set c=%%~dpfdosmc.dir\dosmc.pl
@if not exist "%c%" echo fatal: script not found: %c% 1>&2 & exit /b 1
@for %%f in ("%c%") do set p=%%~dpfperl.exe
@if not exist "%p%" set p=perl
@for %%f in ("%c%") do set r=%%~dpfpreamblew.pm
@if not exist "%r%" echo fatal: preamble not found: %r% 1>&2 && exit /b 1
@goto :last
#!perl -w
BEGIN { $^W = 1 }
@INC = ();  # Perl modules not installed, don't try to load them.
die "$0: fatal: missing arguments\n" if @ARGV < 3;
my($run_prog, $preamble_fn, $script_fn) = splice @ARGV, 0, 3;
$0 = $run_prog;  # Previously $0 contained absolute pathname.
$0 =~ s@[.](exe|cmd)\Z(?!\n)@@i;
die "$0: fatal: preamble not found: $preamble_fn\n" if !-f($preamble_fn);
die "$0: fatal: script not found: $script_fn\n" if !-f($script_fn);
# Makes `require integer;' etc. work.
my $result = do($preamble_fn);  # Absolute pathname.
die $@ if $@;
die "$0: fatal: error loading preamble: $preamble_fn: $!\n" if
    !defined($result) and $!;
$ENV{__SCRIPTFN} = $0; $0 = $script_fn;
$result = do($0);  # Absolute pathname.  !! die $result.
die $@ if $@;
die "$0: fatal: error loading script: $script_fn: $!\n" if
    !defined($result) and $!;
__END__
:last
@"%p%" -x "%m%" "%0" "%r%" "%c%" %*
