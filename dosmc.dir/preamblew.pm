#
# preamble.pm: Win32 Perl 5.10 preamble
# by pts@fazekas.hu at Sun Jul 12 03:27:27 CEST 2020
#
# !! TODO(pts): This file is a verbatim copy of Linux-specific
#    https://github.com/pts/staticperl/blob/master/preamble-5.10.1.pm .
#    Most OS-specific packages (e.g. Errno and File::Glob) won't work.
#    Port it to Win32, possibly compying code from Perl 5.10.1 sources --
#    even easier: remove packages which don't work.
#
# The contents of this file will be embedded into the staticperl executable
# and executed at startup as Perl code.
#
# Currently this file contains some mini package definitions: only a subset
# of the Perl 5.10.1 packages, only Linux is supported, POD documentation
# removed, comments removed, some features removed.
#
# Comments in the beginning of the line will be removed before embedding.
#
# This preamble works for both perl and miniperl (without C extensions).
#
# TODO(pts): Add support for these modules in /usr/lib/perl/5.10.1
#   -rw-r--r-- 1 root root   997 Apr 23  2010 /usr/lib/perl/5.10.1/ops.pm
#   -rw-r--r-- 1 root root  2765 Apr 23  2010 /usr/lib/perl/5.10.1/Config.pm
#   -rw-r--r-- 1 root root  3131 Apr 23  2010 /usr/lib/perl/5.10.1/lib.pm
#   -rw-r--r-- 1 root root  3468 Apr 23  2010 /usr/lib/perl/5.10.1/XSLoader.pm
#   -rw-r--r-- 1 root root  3557 Apr 23  2010 /usr/lib/perl/5.10.1/Fcntl.pm
#   -rw-r--r-- 1 root root 15490 Apr 23  2010 /usr/lib/perl/5.10.1/Opcode.pm
#   -rw-r--r-- 1 root root 19892 Apr 23  2010 /usr/lib/perl/5.10.1/encoding.pm
#   -rw-r--r-- 1 root root 29731 Apr 23  2010 /usr/lib/perl/5.10.1/Encode.pm
#
package Exporter; BEGIN { $INC{"Exporter.pm"} = "Exporter.pm" }
BEGIN {
our $Debug = 0;
our $ExportLevel = 0;
our $Verbose ||= 0;
our $VERSION = '5.63';
our (%Cache);
$Carp::Internal{Exporter}++;
sub as_heavy {
 require Exporter::Heavy;
 my $c = (caller(1))[3];
 $c =~ s/.*:://;
 \&{"Exporter::Heavy::heavy_$c"};
}
sub export {
 goto &{as_heavy()};
}
sub import {
 my $pkg = shift;
 my $callpkg = caller($ExportLevel);
 if ($pkg eq "Exporter" and @_ and $_[0] eq "import") {
  *{$callpkg."::import"} = \&import;
  return;
 }
 my($exports, $fail) = (\@{"$pkg\::EXPORT"}, \@{"$pkg\::EXPORT_FAIL"});
 return export $pkg, $callpkg, @_
  if $Verbose or $Debug or @$fail > 1;
 my $export_cache = ($Cache{$pkg} ||= {});
 my $args = @_ or @_ = @$exports;
 local $_;
 if ($args and not %$export_cache) {
  s/^&//, $export_cache->{$_} = 1
   foreach (@$exports, @{"$pkg\::EXPORT_OK"});
 }
 my $heavy;
 if ($args or $fail) {
  ($heavy = (/\W/ or $args and not exists $export_cache->{$_}
        or @$fail and $_ eq $fail->[0])) and last
         foreach (@_);
 } else {
  ($heavy = /\W/) and last
   foreach (@_);
 }
 return export $pkg, $callpkg, ($args ? @_ : ()) if $heavy;
 local $SIG{__WARN__} = sub {require Carp; &Carp::carp};
 *{"$callpkg\::$_"} = \&{"$pkg\::$_"} foreach @_;
}
sub export_fail {
  my $self = shift;
  @_;
}
sub export_to_level {
 goto &{as_heavy()};
}
sub export_tags {
 goto &{as_heavy()};
}
sub export_ok_tags {
 goto &{as_heavy()};
}
sub require_version {
 goto &{as_heavy()};
}
}
package Carp; BEGIN { $INC{"Carp.pm"} = "Carp.pm" }
BEGIN {
our $VERSION = '1.11';
our $MaxEvalLen = 0;
our $Verbose    = 0;
our $CarpLevel  = 0;
our $MaxArgLen  = 64;
our $MaxArgNums = 8;
our @ISA = ('Exporter');
our @EXPORT = qw(confess croak carp);
our @EXPORT_OK = qw(cluck verbose longmess shortmess);
our @EXPORT_FAIL = qw(verbose);
sub export_fail { shift; $Verbose = shift if $_[0] eq 'verbose'; @_ }
sub longmess  { goto &longmess_jmp }
sub shortmess { goto &shortmess_jmp }
sub shortmess_jmp  { goto &longmess_jmp; }
# Simplified implementation (simpler than Carp::Heavy), no stack trace.
sub longmess_jmp { my $S="@_"; my @C=caller(1); $S .= " at $C[1] line $C[2]\n" if substr($S, -1) ne "\n"; $S }
sub croak   { die  shortmess @_ }
sub confess { die  longmess  @_ }
sub carp    { warn shortmess @_ }
sub cluck   { warn longmess  @_ }
}
package strict; BEGIN { $INC{"strict.pm"} = "strict.pm" }
BEGIN {
$strict::VERSION = "1.04";
%strict::bitmask = (
refs => 0x00000002,
subs => 0x00000200,
vars => 0x00000400
);
sub bits {
 my $bits = 0;
 my @wrong;
 foreach my $s (@_) {
  push @wrong, $s unless exists $strict::bitmask{$s};
  $bits |= $strict::bitmask{$s} || 0;
 }
 if (@wrong) {
  Carp::croak("Unknown 'strict' tag(s) '@wrong'");
 }
 $bits;
}
my $default_bits = bits(qw(refs subs vars));
sub import {
 shift;
 $^H |= @_ ? bits(@_) : $default_bits;
}
sub unimport {
 shift;
 $^H &= ~ (@_ ? bits(@_) : $default_bits);
}
}
# Errno is Linux-specific (2.6.x).
package Errno; BEGIN { $INC{"Errno.pm"} = "Errno.pm" }
BEGIN {
our (@EXPORT_OK,%EXPORT_TAGS,@ISA,$VERSION,%errno,$AUTOLOAD);
use Exporter ();
use strict;
$VERSION = "1.11";
$VERSION = eval $VERSION;
@ISA = qw(Exporter);
@EXPORT_OK = qw(EBADR ENOMSG ENOTSUP ESTRPIPE EADDRINUSE EL3HLT EBADF
  ENOTBLK ENAVAIL ECHRNG ENOTNAM ELNRNG ENOKEY EXDEV EBADE EBADSLT
  ECONNREFUSED ENOSTR ENONET EOVERFLOW EISCONN EFBIG EKEYREVOKED
  ECONNRESET EWOULDBLOCK ELIBMAX EREMOTEIO ERFKILL ENOPKG ELIBSCN
  EDESTADDRREQ ENOTSOCK EIO EMEDIUMTYPE EINPROGRESS ERANGE EAFNOSUPPORT
  EADDRNOTAVAIL EINTR EREMOTE EILSEQ ENOMEM EPIPE ENETUNREACH ENODATA
  EUSERS EOPNOTSUPP EPROTO EISNAM ESPIPE EALREADY ENAMETOOLONG ENOEXEC
  EISDIR EBADRQC EEXIST EDOTDOT ELIBBAD EOWNERDEAD ESRCH EFAULT EXFULL
  EDEADLOCK EAGAIN ENOPROTOOPT ENETDOWN EPROTOTYPE EL2NSYNC ENETRESET
  EUCLEAN EADV EROFS ESHUTDOWN EMULTIHOP EPROTONOSUPPORT ENFILE ENOLCK
  ECONNABORTED ECANCELED EDEADLK ESRMNT ENOLINK ETIME ENOTDIR EINVAL
  ENOTTY ENOANO ELOOP ENOENT EPFNOSUPPORT EBADMSG ENOMEDIUM EL2HLT EDOM
  EBFONT EKEYEXPIRED EMSGSIZE ENOCSI EL3RST ENOSPC EIDRM ENOBUFS ENOSYS
  EHOSTDOWN EBADFD ENOSR ENOTCONN ESTALE EDQUOT EKEYREJECTED EMFILE
  ENOTRECOVERABLE EACCES EBUSY E2BIG EPERM ELIBEXEC ETOOMANYREFS ELIBACC
  ENOTUNIQ ECOMM ERESTART ESOCKTNOSUPPORT EUNATCH ETIMEDOUT ENXIO ENODEV
  ETXTBSY EMLINK ECHILD EHOSTUNREACH EREMCHG ENOTEMPTY);
%EXPORT_TAGS = (
 POSIX => [qw(
  E2BIG EACCES EADDRINUSE EADDRNOTAVAIL EAFNOSUPPORT EAGAIN EALREADY
  EBADF EBUSY ECHILD ECONNABORTED ECONNREFUSED ECONNRESET EDEADLK
  EDESTADDRREQ EDOM EDQUOT EEXIST EFAULT EFBIG EHOSTDOWN EHOSTUNREACH
  EINPROGRESS EINTR EINVAL EIO EISCONN EISDIR ELOOP EMFILE EMLINK
  EMSGSIZE ENAMETOOLONG ENETDOWN ENETRESET ENETUNREACH ENFILE ENOBUFS
  ENODEV ENOENT ENOEXEC ENOLCK ENOMEM ENOPROTOOPT ENOSPC ENOSYS ENOTBLK
  ENOTCONN ENOTDIR ENOTEMPTY ENOTSOCK ENOTTY ENXIO EOPNOTSUPP EPERM
  EPFNOSUPPORT EPIPE EPROTONOSUPPORT EPROTOTYPE ERANGE EREMOTE ERESTART
  EROFS ESHUTDOWN ESOCKTNOSUPPORT ESPIPE ESRCH ESTALE ETIMEDOUT
  ETOOMANYREFS ETXTBSY EUSERS EWOULDBLOCK EXDEV
 )]
);
sub EPERM () { 1 }
sub ENOENT () { 2 }
sub ESRCH () { 3 }
sub EINTR () { 4 }
sub EIO () { 5 }
sub ENXIO () { 6 }
sub E2BIG () { 7 }
sub ENOEXEC () { 8 }
sub EBADF () { 9 }
sub ECHILD () { 10 }
sub EWOULDBLOCK () { 11 }
sub EAGAIN () { 11 }
sub ENOMEM () { 12 }
sub EACCES () { 13 }
sub EFAULT () { 14 }
sub ENOTBLK () { 15 }
sub EBUSY () { 16 }
sub EEXIST () { 17 }
sub EXDEV () { 18 }
sub ENODEV () { 19 }
sub ENOTDIR () { 20 }
sub EISDIR () { 21 }
sub EINVAL () { 22 }
sub ENFILE () { 23 }
sub EMFILE () { 24 }
sub ENOTTY () { 25 }
sub ETXTBSY () { 26 }
sub EFBIG () { 27 }
sub ENOSPC () { 28 }
sub ESPIPE () { 29 }
sub EROFS () { 30 }
sub EMLINK () { 31 }
sub EPIPE () { 32 }
sub EDOM () { 33 }
sub ERANGE () { 34 }
sub EDEADLOCK () { 35 }
sub EDEADLK () { 35 }
sub ENAMETOOLONG () { 36 }
sub ENOLCK () { 37 }
sub ENOSYS () { 38 }
sub ENOTEMPTY () { 39 }
sub ELOOP () { 40 }
sub ENOMSG () { 42 }
sub EIDRM () { 43 }
sub ECHRNG () { 44 }
sub EL2NSYNC () { 45 }
sub EL3HLT () { 46 }
sub EL3RST () { 47 }
sub ELNRNG () { 48 }
sub EUNATCH () { 49 }
sub ENOCSI () { 50 }
sub EL2HLT () { 51 }
sub EBADE () { 52 }
sub EBADR () { 53 }
sub EXFULL () { 54 }
sub ENOANO () { 55 }
sub EBADRQC () { 56 }
sub EBADSLT () { 57 }
sub EBFONT () { 59 }
sub ENOSTR () { 60 }
sub ENODATA () { 61 }
sub ETIME () { 62 }
sub ENOSR () { 63 }
sub ENONET () { 64 }
sub ENOPKG () { 65 }
sub EREMOTE () { 66 }
sub ENOLINK () { 67 }
sub EADV () { 68 }
sub ESRMNT () { 69 }
sub ECOMM () { 70 }
sub EPROTO () { 71 }
sub EMULTIHOP () { 72 }
sub EDOTDOT () { 73 }
sub EBADMSG () { 74 }
sub EOVERFLOW () { 75 }
sub ENOTUNIQ () { 76 }
sub EBADFD () { 77 }
sub EREMCHG () { 78 }
sub ELIBACC () { 79 }
sub ELIBBAD () { 80 }
sub ELIBSCN () { 81 }
sub ELIBMAX () { 82 }
sub ELIBEXEC () { 83 }
sub EILSEQ () { 84 }
sub ERESTART () { 85 }
sub ESTRPIPE () { 86 }
sub EUSERS () { 87 }
sub ENOTSOCK () { 88 }
sub EDESTADDRREQ () { 89 }
sub EMSGSIZE () { 90 }
sub EPROTOTYPE () { 91 }
sub ENOPROTOOPT () { 92 }
sub EPROTONOSUPPORT () { 93 }
sub ESOCKTNOSUPPORT () { 94 }
sub ENOTSUP () { 95 }
sub EOPNOTSUPP () { 95 }
sub EPFNOSUPPORT () { 96 }
sub EAFNOSUPPORT () { 97 }
sub EADDRINUSE () { 98 }
sub EADDRNOTAVAIL () { 99 }
sub ENETDOWN () { 100 }
sub ENETUNREACH () { 101 }
sub ENETRESET () { 102 }
sub ECONNABORTED () { 103 }
sub ECONNRESET () { 104 }
sub ENOBUFS () { 105 }
sub EISCONN () { 106 }
sub ENOTCONN () { 107 }
sub ESHUTDOWN () { 108 }
sub ETOOMANYREFS () { 109 }
sub ETIMEDOUT () { 110 }
sub ECONNREFUSED () { 111 }
sub EHOSTDOWN () { 112 }
sub EHOSTUNREACH () { 113 }
sub EALREADY () { 114 }
sub EINPROGRESS () { 115 }
sub ESTALE () { 116 }
sub EUCLEAN () { 117 }
sub ENOTNAM () { 118 }
sub ENAVAIL () { 119 }
sub EISNAM () { 120 }
sub EREMOTEIO () { 121 }
sub EDQUOT () { 122 }
sub ENOMEDIUM () { 123 }
sub EMEDIUMTYPE () { 124 }
sub ECANCELED () { 125 }
sub ENOKEY () { 126 }
sub EKEYEXPIRED () { 127 }
sub EKEYREVOKED () { 128 }
sub EKEYREJECTED () { 129 }
sub EOWNERDEAD () { 130 }
sub ENOTRECOVERABLE () { 131 }
sub ERFKILL () { 132 }
sub TIEHASH { bless [] }
sub FETCH {
 my ($self, $errname) = @_;
 my $proto = prototype("Errno::$errname");
 my $errno = "";
 if (defined($proto) && $proto eq "") {
  no strict 'refs';
  $errno = &$errname;
  $errno = 0 unless $! == $errno;
 }
 return $errno;
}
sub STORE {
 require Carp;
 Carp::confess("ERRNO hash is read only!");
}
*CLEAR = \&STORE;
*DELETE = \&STORE;
sub NEXTKEY {
 my($k,$v);
 while(($k,$v) = each %Errno::) {
  my $proto = prototype("Errno::$k");
  last if (defined($proto) && $proto eq "");
 }
 $k
}
sub FIRSTKEY {
 my $s = scalar keys %Errno::;
 goto &NEXTKEY;
}
sub EXISTS {
 my ($self, $errname) = @_;
 my $r = ref $errname;
 my $proto = !$r || $r eq 'CODE' ? prototype($errname) : undef;
 defined($proto) && $proto eq "";
}
tie %!, __PACKAGE__;
}
package base; BEGIN { $INC{"base.pm"} = "base.pm" }
BEGIN{
use strict 'vars';
$base::VERSION = 2.14;
sub SUCCESS () { 1 }
sub PUBLIC     () { 2**0  }
sub PRIVATE    () { 2**1  }
sub INHERITED  () { 2**2  }
sub PROTECTED  () { 2**3  }
my $Fattr = \%fields::attr;
sub has_fields {
 my($base) = shift;
 my $fglob = ${"$base\::"}{FIELDS};
 return( ($fglob && 'GLOB' eq ref($fglob) && *$fglob{HASH}) ? 1 : 0 );
}
sub has_version {
 my($base) = shift;
 my $vglob = ${$base.'::'}{VERSION};
 return( ($vglob && *$vglob{SCALAR}) ? 1 : 0 );
}
sub has_attr {
 my($proto) = shift;
 my($class) = ref $proto || $proto;
 return exists $Fattr->{$class};
}
sub get_attr {
 $Fattr->{$_[0]} = [1] unless $Fattr->{$_[0]};
 return $Fattr->{$_[0]};
}
if ($] < 5.009) {
 *get_fields = sub {
  () = \%{$_[0].'::FIELDS'};
  my $f = \%{$_[0].'::FIELDS'};
  bless $f, 'pseudohash' if (ref($f) ne 'pseudohash');
  return $f;
 }
}
else {
 *get_fields = sub {
  () = \%{$_[0].'::FIELDS'};
  return \%{$_[0].'::FIELDS'};
 }
}
sub import {
 my $class = shift;
 return SUCCESS unless @_;
 my $fields_base;
 my $inheritor = caller(0);
 my @isa_classes;
 my @bases;
 foreach my $base (@_) {
  if ( $inheritor eq $base ) {
   warn "Class '$inheritor' tried to inherit from itself\n";
  }
  next if grep $_->isa($base), ($inheritor, @bases);
  if (has_version($base)) {
   ${$base.'::VERSION'} = '-1, set by base.pm'
     unless defined ${$base.'::VERSION'};
  } else {
   my $sigdie;
   {
    local $SIG{__DIE__};
    eval "require $base";
    die if $@ && $@ !~ /^Can't locate .*? at \(eval /;
    unless (%{"$base\::"}) {
     local $" = " ";
     Carp::croak("Base class package \"$base\" is empty.\n    (Perhaps you need to 'use' the module which defines that package first,\n    or make that module available in \@INC (\@INC contains: @INC).\n");
    }
    $sigdie = $SIG{__DIE__} || undef;
   }
   $SIG{__DIE__} = $sigdie if defined $sigdie;
   ${$base.'::VERSION'} = "-1, set by base.pm"
     unless defined ${$base.'::VERSION'};
  }
  push @bases, $base;
  if ( has_fields($base) || has_attr($base) ) {
   if ($fields_base) {
    Carp::croak("Can't multiply inherit fields");
   } else {
    $fields_base = $base;
   }
  }
 }
 push @{"$inheritor\::ISA"}, @isa_classes;
 push @{"$inheritor\::ISA"}, @bases;
 if( defined $fields_base ) {
  inherit_fields($inheritor, $fields_base);
 }
}
sub inherit_fields {
 my($derived, $base) = @_;
 return SUCCESS unless $base;
 my $battr = get_attr($base);
 my $dattr = get_attr($derived);
 my $dfields = get_fields($derived);
 my $bfields = get_fields($base);
 $dattr->[0] = @$battr;
 if( keys %$dfields ) {
  warn "$derived is inheriting from $base but already has its own fields!\nThis will cause problems.  Be sure you use base BEFORE declaring fields.\n";
 }
 while (my($k,$v) = each %$bfields) {
  my $fno;
  if ($fno = $dfields->{$k} and $fno != $v) {
   Carp::croak ("Inherited fields can't override existing fields");
  }
  if( $battr->[$v] & PRIVATE ) {
   $dattr->[$v] = PRIVATE | INHERITED;
  } else {
   $dattr->[$v] = INHERITED | $battr->[$v];
   $dfields->{$k} = $v;
  }
 }
 foreach my $idx (1..$#{$battr}) {
  next if defined $dattr->[$idx];
  $dattr->[$idx] = $battr->[$idx] & INHERITED;
 }
}
}
package warnings; BEGIN { $INC{"warnings.pm"} = "warnings.pm" }
BEGIN {
$warnings::VERSION = '1.06';
%warnings::Offsets = (
 'all'  => 0,
 'closure'  => 2,
 'deprecated' => 4,
 'exiting'  => 6,
 'glob'  => 8,
 'io'  => 10,
 'closed'  => 12,
 'exec'  => 14,
 'layer'  => 16,
 'newline'  => 18,
 'pipe'  => 20,
 'unopened'  => 22,
 'misc'  => 24,
 'numeric'  => 26,
 'once'  => 28,
 'overflow'  => 30,
 'pack'  => 32,
 'portable'  => 34,
 'recursion'  => 36,
 'redefine'  => 38,
 'regexp'  => 40,
 'severe'  => 42,
 'debugging'  => 44,
 'inplace'  => 46,
 'internal'  => 48,
 'malloc'  => 50,
 'signal'  => 52,
 'substr'  => 54,
 'syntax'  => 56,
 'ambiguous'  => 58,
 'bareword'  => 60,
 'digit'  => 62,
 'parenthesis' => 64,
 'precedence' => 66,
 'printf'  => 68,
 'prototype'  => 70,
 'qw'  => 72,
 'reserved'  => 74,
 'semicolon'  => 76,
 'taint'  => 78,
 'threads'  => 80,
 'uninitialized' => 82,
 'unpack'  => 84,
 'untie'  => 86,
 'utf8'  => 88,
 'void'  => 90,
  );
%warnings::Bits = (
 'all'  => "\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x05",
 'ambiguous'  => "\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00",
 'bareword'  => "\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00",
 'closed'  => "\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'closure'  => "\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'debugging'  => "\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00",
 'deprecated' => "\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'digit'  => "\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00",
 'exec'  => "\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'exiting'  => "\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'glob'  => "\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'inplace'  => "\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00",
 'internal'  => "\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00",
 'io'  => "\x00\x54\x55\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'layer'  => "\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'malloc'  => "\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00",
 'misc'  => "\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00",
 'newline'  => "\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'numeric'  => "\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00",
 'once'  => "\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00",
 'overflow'  => "\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00",
 'pack'  => "\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00",
 'parenthesis' => "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00",
 'pipe'  => "\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'portable'  => "\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00",
 'precedence' => "\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00",
 'printf'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00",
 'prototype'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00",
 'qw'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00",
 'recursion'  => "\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00",
 'redefine'  => "\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00",
 'regexp'  => "\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00",
 'reserved'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00",
 'semicolon'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00",
 'severe'  => "\x00\x00\x00\x00\x00\x54\x05\x00\x00\x00\x00\x00",
 'signal'  => "\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00",
 'substr'  => "\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00",
 'syntax'  => "\x00\x00\x00\x00\x00\x00\x00\x55\x55\x15\x00\x00",
 'taint'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00",
 'threads'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00",
 'uninitialized' => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00",
 'unopened'  => "\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'unpack'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00",
 'untie'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00",
 'utf8'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01",
 'void'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04",
  );
%warnings::DeadBits = (
 'all'  => "\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\x0a",
 'ambiguous'  => "\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00",
 'bareword'  => "\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00",
 'closed'  => "\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'closure'  => "\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'debugging'  => "\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00",
 'deprecated' => "\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'digit'  => "\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00",
 'exec'  => "\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'exiting'  => "\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'glob'  => "\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'inplace'  => "\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00",
 'internal'  => "\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00",
 'io'  => "\x00\xa8\xaa\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'layer'  => "\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'malloc'  => "\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00",
 'misc'  => "\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00",
 'newline'  => "\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'numeric'  => "\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00",
 'once'  => "\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00",
 'overflow'  => "\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00",
 'pack'  => "\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00",
 'parenthesis' => "\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00",
 'pipe'  => "\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'portable'  => "\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00",
 'precedence' => "\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00",
 'printf'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00",
 'prototype'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00",
 'qw'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00",
 'recursion'  => "\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00\x00\x00",
 'redefine'  => "\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00",
 'regexp'  => "\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00",
 'reserved'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00",
 'semicolon'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00\x00",
 'severe'  => "\x00\x00\x00\x00\x00\xa8\x0a\x00\x00\x00\x00\x00",
 'signal'  => "\x00\x00\x00\x00\x00\x00\x20\x00\x00\x00\x00\x00",
 'substr'  => "\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00",
 'syntax'  => "\x00\x00\x00\x00\x00\x00\x00\xaa\xaa\x2a\x00\x00",
 'taint'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00",
 'threads'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00",
 'uninitialized' => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00",
 'unopened'  => "\x00\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00",
 'unpack'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00",
 'untie'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x00",
 'utf8'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02",
 'void'  => "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08",
  );
$NONE     = "\0\0\0\0\0\0\0\0\0\0\0\0";
$LAST_BIT = 92 ;
$BYTES    = 12 ;
$All = "" ; vec($All, $Offsets{'all'}, 2) = 3 ;
sub Croaker
{
 Carp::croak(@_);
}
sub bits
{
 push @_, 'all' unless @_;
 my $mask;
 my $catmask ;
 my $fatal = 0 ;
 my $no_fatal = 0 ;
 foreach my $word ( @_ ) {
  if ($word eq 'FATAL') {
   $fatal = 1;
   $no_fatal = 0;
  } elsif ($word eq 'NONFATAL') {
   $fatal = 0;
   $no_fatal = 1;
  } elsif ($catmask = $Bits{$word}) {
   $mask |= $catmask ;
   $mask |= $DeadBits{$word} if $fatal ;
   $mask &= ~($DeadBits{$word}|$All) if $no_fatal ;
  } else
    { Croaker("Unknown warnings category '$word'")}
 }
 return $mask ;
}
sub import {
 shift;
 my $catmask ;
 my $fatal = 0 ;
 my $no_fatal = 0 ;
 my $mask = ${^WARNING_BITS} ;
 if (vec($mask, $Offsets{'all'}, 1)) {
  $mask |= $Bits{'all'} ;
  $mask |= $DeadBits{'all'} if vec($mask, $Offsets{'all'}+1, 1);
 }
 push @_, 'all' unless @_;
 foreach my $word ( @_ ) {
  if ($word eq 'FATAL') {
   $fatal = 1;
   $no_fatal = 0;
  } elsif ($word eq 'NONFATAL') {
   $fatal = 0;
   $no_fatal = 1;
  } elsif ($catmask = $Bits{$word}) {
   $mask |= $catmask ;
   $mask |= $DeadBits{$word} if $fatal ;
   $mask &= ~($DeadBits{$word}|$All) if $no_fatal ;
  } else
    { Croaker("Unknown warnings category '$word'")}
 }
 ${^WARNING_BITS} = $mask ;
}
sub unimport {
 shift;
 my $catmask ;
 my $mask = ${^WARNING_BITS} ;
 if (vec($mask, $Offsets{'all'}, 1)) {
  $mask |= $Bits{'all'} ;
  $mask |= $DeadBits{'all'} if vec($mask, $Offsets{'all'}+1, 1);
 }
 push @_, 'all' unless @_;
 foreach my $word ( @_ ) {
  if ($word eq 'FATAL') {
   next;
  } elsif ($catmask = $Bits{$word}) {
   $mask &= ~($catmask | $DeadBits{$word} | $All);
  } else
    { Croaker("Unknown warnings category '$word'")}
 }
 ${^WARNING_BITS} = $mask ;
}
my %builtin_type; @builtin_type{qw(SCALAR ARRAY HASH CODE REF GLOB LVALUE Regexp)} = ();
sub __chk
{
 my $category ;
 my $offset ;
 my $isobj = 0 ;
 if (@_) {
  $category = shift ;
  if (my $type = ref $category) {
   Croaker("not an object")
    if exists $builtin_type{$type};
   $category = $type;
   $isobj = 1 ;
  }
  $offset = $Offsets{$category};
  Croaker("Unknown warnings category '$category'")
   unless defined $offset;
 } else {
  $category = (caller(1))[0] ;
  $offset = $Offsets{$category};
  Croaker("package '$category' not registered for warnings")
   unless defined $offset ;
 }
 my $this_pkg = (caller(1))[0] ;
 my $i = 2 ;
 my $pkg ;
 if ($isobj) {
  while (do { { package DB; $pkg = (caller($i++))[0] } } ) {
   last unless @DB::args && $DB::args[0] =~ /^$category=/ ;
  }
  $i -= 2 ;
 } else {
  $i = _error_loc();
 }
 my $callers_bitmask = (caller($i))[9] ;
 return ($callers_bitmask, $offset, $i) ;
}
sub _error_loc {
 require Carp::Heavy;
 goto &Carp::short_error_loc;
}
sub enabled {
 Croaker("Usage: warnings::enabled([category])")
  unless @_ == 1 || @_ == 0 ;
 my ($callers_bitmask, $offset, $i) = __chk(@_) ;
 return 0 unless defined $callers_bitmask ;
 return vec($callers_bitmask, $offset, 1) ||
     vec($callers_bitmask, $Offsets{'all'}, 1) ;
}
sub warn
{
 Croaker("Usage: warnings::warn([category,] 'message')")
  unless @_ == 2 || @_ == 1 ;
 my $message = pop ;
 my ($callers_bitmask, $offset, $i) = __chk(@_) ;
 Carp::croak($message)
  if vec($callers_bitmask, $offset+1, 1) ||
     vec($callers_bitmask, $Offsets{'all'}+1, 1) ;
 Carp::carp($message) ;
}
sub warnif
{
 Croaker("Usage: warnings::warnif([category,] 'message')")
  unless @_ == 2 || @_ == 1 ;
 my $message = pop ;
 my ($callers_bitmask, $offset, $i) = __chk(@_) ;
 return
  unless defined $callers_bitmask &&
    (vec($callers_bitmask, $offset, 1) ||
    vec($callers_bitmask, $Offsets{'all'}, 1)) ;
 Carp::croak($message)
  if vec($callers_bitmask, $offset+1, 1) ||
     vec($callers_bitmask, $Offsets{'all'}+1, 1) ;
 Carp::carp($message) ;
}
}
package overload::numbers; BEGIN { $INC{"overload/numbers.pm"} = "overload/numbers.pm" }
BEGIN {
@overload::numbers::names = qw`
 ()
 (${}
 (@{}
 (%{}
 (*{}
 (&{}
 (++
 (--
 (bool
 (0+
 (""
 (!
 (=
 (abs
 (neg
 (<>
 (int
 (<
 (<=
 (>
 (>=
 (==
 (!=
 (lt
 (le
 (gt
 (ge
 (eq
 (ne
 (nomethod
 (+
 (+=
 (-
 (-=
 (*
 (*=
 (/
 (/=
 (%
 (%=
 (**
 (**=
 (<<
 (<<=
 (>>
 (>>=
 (&
 (&=
 (|
 (|=
 (^
 (^=
 (<=>
 (cmp
 (~
 (atan2
 (cos
 (sin
 (exp
 (log
 (sqrt
 (x
 (x=
 (.
 (.=
 (~~
 DESTROY
`;
@overload::numbers::enums = qw`
 fallback
 to_sv
 to_av
 to_hv
 to_gv
 to_cv
 inc
 dec
 bool_
 numer
 string
 not
 copy
 abs
 neg
 iter
 int
 lt
 le
 gt
 ge
 eq
 ne
 slt
 sle
 sgt
 sge
 seq
 sne
 nomethod
 add
 add_ass
 subtr
 subtr_ass
 mult
 mult_ass
 div
 div_ass
 modulo
 modulo_ass
 pow
 pow_ass
 lshift
 lshift_ass
 rshift
 rshift_ass
 band
 band_ass
 bor
 bor_ass
 bxor
 bxor_ass
 ncmp
 scmp
 compl
 atan2
 cos
 sin
 exp
 log
 sqrt
 repeat
 repeat_ass
 concat
 concat_ass
 smart
 DESTROY
`;
{ my $i = 0; %overload::numbers::names = map { $_ => $i++ } @names }
{ my $i = 0; %overload::numbers::enums = map { $_ => $i++ } @enums }
}
package locale; BEGIN { $INC{"locale.pm"} = "locale.pm" }
BEGIN {
$locale::VERSION = '1.00';
$locale::hint_bits = 0x4;
sub import {
 $^H |= $locale::hint_bits;
}
sub unimport {
 $^H &= ~$locale::hint_bits;
}
}
package integer; BEGIN { $INC{"integer.pm"} = "integer.pm" }
BEGIN {
$integer::VERSION = '1.00';
$integer::hint_bits = 0x1;
sub import {
 $^H |= $integer::hint_bits;
}
sub unimport {
 $^H &= ~$integer::hint_bits;
}
}
package Symbol; BEGIN { $INC{"Symbol.pm"} = "Symbol.pm" }
BEGIN {
@ISA = qw(Exporter);
@EXPORT = qw(gensym ungensym qualify qualify_to_ref);
@EXPORT_OK = qw(delete_package geniosym);
$VERSION = '1.07';
my $genpkg = "Symbol::";
my $genseq = 0;
my %global = map {$_ => 1} qw(ARGV ARGVOUT ENV INC SIG STDERR STDIN STDOUT);
sub gensym () {
 my $name = "GEN" . $genseq++;
 my $ref = \*{$genpkg . $name};
 delete $$genpkg{$name};
 $ref;
}
sub geniosym () {
 my $sym = gensym();
 select(select $sym);
 *$sym{IO};
}
sub ungensym ($) {}
sub qualify ($;$) {
 my ($name) = @_;
 if (!ref($name) && index($name, '::') == -1 && index($name, "'") == -1) {
  my $pkg;
  if ($name =~ /^(([^a-z])|(\^[a-z_]+))\z/i || $global{$name}) {
   $name =~ s/^\^([a-z_])/'qq(\c'.$1.')'/eei;
   $pkg = "main";
  } else {
   $pkg = (@_ > 1) ? $_[1] : caller;
  }
  $name = $pkg . "::" . $name;
 }
 $name;
}
sub qualify_to_ref ($;$) {
 return \*{ qualify $_[0], @_ > 1 ? $_[1] : caller };
}
sub delete_package ($) {
 my $pkg = shift;
 unless ($pkg =~ /^main::.*::$/) {
  $pkg = "main$pkg" if $pkg =~ /^::/;
  $pkg = "main::$pkg" unless $pkg =~ /^main::/;
  $pkg .= '::'  unless $pkg =~ /::$/;
 }
 my($stem, $leaf) = $pkg =~ m/(.*::)(\w+::)$/;
 my $stem_symtab = *{$stem}{HASH};
 return unless defined $stem_symtab and exists $stem_symtab->{$leaf};
 my $leaf_symtab = *{$stem_symtab->{$leaf}}{HASH};
 foreach my $name (keys %$leaf_symtab) {
  undef *{$pkg . $name};
 }
 %$leaf_symtab = ();
 delete $stem_symtab->{$leaf};
}
}
package SelectSaver; BEGIN { $INC{"SelectSaver.pm"} = "SelectSaver.pm" }
BEGIN{
$SelectSaver::VERSION = '1.02';
sub new {
 @_ >= 1 && @_ <= 2 or Carp::croak('usage: SelectSaver->new( [FILEHANDLE] )');
 my $fh = select;
 my $self = bless \$fh, $_[0];
 select Symbol::qualify($_[1], caller) if @_ > 1;
 $self;
}
sub DESTROY {
 my $self = $_[0];
 select $$self;
}
}
package utf8; BEGIN { $INC{"utf8.pm"} = "utf8.pm" }
BEGIN {
$utf8::hint_bits = 0x00800000;
$utf8::VERSION = '1.07';
sub import {
 $^H |= $utf8::hint_bits;
 $enc{caller()} = $_[1] if $_[1];
}
sub unimport {
 $^H &= ~$utf8::hint_bits;
}
sub AUTOLOAD {
 require "utf8_heavy.pl";
 goto &$AUTOLOAD if defined &$AUTOLOAD;
 Carp::croak("Undefined subroutine $AUTOLOAD called");
}
}
package bytes; BEGIN { $INC{"bytes.pm"} = "bytes.pm" }
BEGIN {
$bytes::VERSION = '1.03';
$bytes::hint_bits = 0x00000008;
sub import {
 $^H |= $bytes::hint_bits;
}
sub unimport {
 $^H &= ~$bytes::hint_bits;
}
sub AUTOLOAD {
 require "bytes_heavy.pl";
 goto &$AUTOLOAD if defined &$AUTOLOAD;
 Carp::croak("Undefined subroutine $AUTOLOAD called");
}
sub length (_);
sub chr (_);
sub ord (_);
sub substr ($$;$$);
sub index ($$;$);
sub rindex ($$;$);
}
package subs; BEGIN { $INC{"subs.pm"} = "subs.pm" }
BEGIN {
$subs::VERSION = '1.00';
sub import {
 my $callpack = caller;
 my $pack = shift;
 my @imports = @_;
 foreach $sym (@imports) {
  *{"${callpack}::$sym"} = \&{"${callpack}::$sym"};
 }
};
}
package warnings::register; BEGIN { $INC{"warnings/register.pm"} = "warnings/register.pm" }
BEGIN {
$warnings::register::VERSION = '1.01';
sub mkMask
{
 my ($bit) = @_;
 my $mask = "";
 vec($mask, $bit, 1) = 1;
 return $mask;
}
sub import
{
 shift;
 my $package = (caller(0))[0];
 if (! defined $warnings::Bits{$package}) {
  $warnings::Bits{$package}     = mkMask($warnings::LAST_BIT);
  vec($warnings::Bits{'all'}, $warnings::LAST_BIT, 1) = 1;
  $warnings::Offsets{$package}  = $warnings::LAST_BIT ++;
  foreach my $k (keys %warnings::Bits) {
   vec($warnings::Bits{$k}, $warnings::LAST_BIT, 1) = 0;
  }
  $warnings::DeadBits{$package} = mkMask($warnings::LAST_BIT);
  vec($warnings::DeadBits{'all'}, $warnings::LAST_BIT++, 1) = 1;
 }
}
}
package vars; BEGIN { $INC{"vars.pm"} = "vars.pm" }
BEGIN {
$vars::VERSION = '1.01';
use warnings::register;
use strict qw(vars subs);
sub import {
 my $callpack = caller;
 my ($pack, @imports) = @_;
 my ($sym, $ch);
 foreach (@imports) {
  if (($ch, $sym) = /^([\$\@\%\*\&])(.+)/) {
   if ($sym =~ /\W/) {
    if ($sym =~ /^\w+[[{].*[]}]$/) {
     Carp::croak("Can't declare individual elements of hash or array");
    } elsif (warnings::enabled() and length($sym) == 1 and $sym !~ tr/a-zA-Z//) {
     warnings::warn("No need to declare built-in vars");
    } elsif  (($^H &= strict::bits('vars'))) {
     Carp::croak("'$_' is not a valid variable name under strict vars");
    }
   }
   $sym = "${callpack}::$sym" unless $sym =~ /::/;
   *$sym =
    (  $ch eq "\$" ? \$$sym
     : $ch eq "\@" ? \@$sym
     : $ch eq "\%" ? \%$sym
     : $ch eq "\*" ? \*$sym
     : $ch eq "\&" ? \&$sym
     : do {
      Carp::croak("'$_' is not a valid variable name");
     });
  } else {
   Carp::croak("'$_' is not a valid variable name");
  }
 }
};
}
package version; BEGIN { $INC{"version.pm"} = "version.pm" }
BEGIN {
use strict;
use vars qw(@ISA $VERSION $CLASS *declare *qv);
$VERSION = 0.77;
$CLASS = 'version';
sub import {
 no strict 'refs';
 my ($class) = shift;
 unless ($class eq 'version') {
  local $^W;
  *{$class.'::declare'} =  \&version::declare;
  *{$class.'::qv'} = \&version::qv;
 }
 my %args;
 if (@_) {
  map { $args{$_} = 1 } @_
 } else {
  %args = (
   qv => 1,
   'UNIVERSAL::VERSION' => 1,
  );
 }
 my $callpkg = caller();
 if (exists($args{declare})) {
  *{$callpkg."::declare"} = sub {return $class->declare(shift) }
    unless defined(&{$callpkg.'::declare'});
 }
 if (exists($args{qv})) {
  *{$callpkg."::qv"} =
   sub {return $class->qv(shift) }
    unless defined(&{"$callpkg\::qv"});
 }
 if (exists($args{'VERSION'})) {
  *{$callpkg."::VERSION"} = \&version::_VERSION;
 }
}
}
package if; BEGIN { $INC{"if.pm"} = "if.pm" }
BEGIN {
$VERSION = '0.05';
sub work {
  my $method = shift() ? 'import' : 'unimport';
  die "Too few arguments to `use if' (some code returning an empty list in list context?)"
      if @_ < 2;
  return unless shift;
  my $p = $_[0];
  (my $file = "$p.pm") =~ s!::!/!g;
  require $file;
  my $m = $p->can($method);
  goto &$m if $m;
}
sub import   { shift; unshift @_, 1; goto &work }
sub unimport { shift; unshift @_, 0; goto &work }
}
package overloading; BEGIN { $INC{"overloading.pm"} = "overloading.pm" }
BEGIN {
use warnings;
no warnings qw(redefine);
use Carp ();
$overloading::VERSION = '0.01';
my $HINT_NO_AMAGIC = 0x01000000;
sub _ops_to_nums {
 map { exists $overload::numbers::names{"($_"}
  ? $overload::numbers::names{"($_"}
  : Carp::croak("'$_' is not a valid overload")
 } @_;
}
sub import {
 my ( $class, @ops ) = @_;
 if ( @ops ) {
  if ( $^H{overloading} ) {
   vec($^H{overloading} , $_, 1) = 0 for _ops_to_nums(@ops);
  }
  if ( $^H{overloading} !~ /[^\0]/ ) {
   delete $^H{overloading};
   $^H &= ~$HINT_NO_AMAGIC;
  }
 } else {
  delete $^H{overloading};
  $^H &= ~$HINT_NO_AMAGIC;
 }
}
sub unimport {
 my ( $class, @ops ) = @_;
 if ( exists $^H{overloading} or not $^H & $HINT_NO_AMAGIC ) {
  if ( @ops ) {
   vec($^H{overloading} ||= '', $_, 1) = 1 for _ops_to_nums(@ops);
  } else {
   delete $^H{overloading};
  }
 }
 $^H |= $HINT_NO_AMAGIC;
}
}
package DirHandle; BEGIN { $INC{"DirHandle.pm"} = "DirHandle.pm" }
BEGIN {
$DirHandle::VERSION = '1.03';
use Carp;
use Symbol;
sub new {
 @_ >= 1 && @_ <= 2 or croak 'usage: DirHandle->new( [DIRNAME] )';
 my $class = shift;
 my $dh = gensym;
 if (@_) {
  DirHandle::open($dh, $_[0])
   or return undef;
 }
 bless $dh, $class;
}
sub DESTROY {
 my ($dh) = @_;
 local($., $@, $!, $^E, $?);
 no warnings 'io';
 closedir($dh);
}
sub open {
 @_ == 2 or croak 'usage: $dh->open(DIRNAME)';
 my ($dh, $dirname) = @_;
 opendir($dh, $dirname);
}
sub close {
 @_ == 1 or croak 'usage: $dh->close()';
 my ($dh) = @_;
 closedir($dh);
}
sub read {
 @_ == 1 or croak 'usage: $dh->read()';
 my ($dh) = @_;
 readdir($dh);
}
sub rewind {
 @_ == 1 or croak 'usage: $dh->rewind()';
 my ($dh) = @_;
 rewinddir($dh);
}
}
package attributes; BEGIN { $INC{"attributes.pm"} = "attributes.pm" }
BEGIN {
$attributes::VERSION = 0.09;
@EXPORT_OK = qw(get reftype);
@EXPORT = ();
%EXPORT_TAGS = (ALL => [@EXPORT, @EXPORT_OK]);
use strict;
sub croak {
 goto &Carp::croak;
}
sub carp {
 goto &Carp::carp;
}
BEGIN { bootstrap attributes }
sub import {
 @_ > 2 && ref $_[2] or do {
  require Exporter;
  goto &Exporter::import;
 };
 my (undef,$home_stash,$svref,@attrs) = @_;
 my $svtype = uc reftype($svref);
 my $pkgmeth;
 $pkgmeth = UNIVERSAL::can($home_stash, "MODIFY_${svtype}_ATTRIBUTES")
  if defined $home_stash && $home_stash ne '';
 my @badattrs;
 if ($pkgmeth) {
  my @pkgattrs = _modify_attrs($svref, @attrs);
  @badattrs = $pkgmeth->($home_stash, $svref, @pkgattrs);
  if (!@badattrs && @pkgattrs) {
   return unless warnings::enabled('reserved');
   @pkgattrs = grep { m/\A[[:lower:]]+(?:\z|\()/ } @pkgattrs;
   if (@pkgattrs) {
    for my $attr (@pkgattrs) {
     $attr =~ s/\(.+\z//s;
    }
    my $s = ((@pkgattrs == 1) ? '' : 's');
    carp "$svtype package attribute$s " .
     "may clash with future reserved word$s: " .
     join(' : ' , @pkgattrs);
   }
  }
 } else {
  @badattrs = _modify_attrs($svref, @attrs);
 }
 if (@badattrs) {
  croak "Invalid $svtype attribute" .
   (( @badattrs == 1 ) ? '' : 's') .
   ": " .
   join(' : ', @badattrs);
 }
}
sub get ($) {
 @_ == 1  && ref $_[0] or
  croak 'Usage: '.__PACKAGE__.'::get $ref';
 my $svref = shift;
 my $svtype = uc reftype $svref;
 my $stash = _guess_stash $svref;
 $stash = caller unless defined $stash;
 my $pkgmeth;
 $pkgmeth = UNIVERSAL::can($stash, "FETCH_${svtype}_ATTRIBUTES")
  if defined $stash && $stash ne '';
 return $pkgmeth ?
    (_fetch_attrs($svref), $pkgmeth->($stash, $svref)) :
    (_fetch_attrs($svref))
  ;
}
sub require_version { goto &UNIVERSAL::VERSION }
}
package parent; BEGIN { $INC{"parent.pm"} = "parent.pm" }
BEGIN {
use strict;
use vars qw($VERSION);
$VERSION = '0.221';
sub import {
 my $class = shift;
 my $inheritor = caller(0);
 if ( @_ and $_[0] eq '-norequire' ) {
  shift @_;
 } else {
  for ( my @filename = @_ ) {
   if ( $_ eq $inheritor ) {
    warn "Class '$inheritor' tried to inherit from itself\n";
   };
   s{::|'}{/}g;
   require "$_.pm";
  }
 }
 {
  no strict 'refs';
  @{"$inheritor\::ISA"} = (@{"$inheritor\::ISA"} , @_);
 };
};
}
package less; BEGIN { $INC{"less.pm"} = "less.pm" }
BEGIN {
use strict;
use warnings;
no warnings qw(redefine);
$less::VERSION = '0.02';
sub _pack_tags {
 return join ' ', @_;
}
sub _unpack_tags {
 return grep { defined and length }
  map  { split ' ' }
  grep {defined} @_;
}
sub of {
 my $class = shift @_;
 return unless defined wantarray;
 my $hinthash = ( caller 0 )[10];
 my %tags;
 @tags{ _unpack_tags( $hinthash->{$class} ) } = ();
 if (@_) {
  exists $tags{$_} and return !!1 for @_;
  return;
 } else {
  return keys %tags;
 }
}
sub import {
 my $class = shift @_;
 @_ = 'please' if not @_;
 my %tags;
 @tags{ _unpack_tags( @_, $^H{$class} ) } = ();
 $^H{$class} = _pack_tags( keys %tags );
 return;
}
sub unimport {
 my $class = shift @_;
 if (@_) {
  my %tags;
  @tags{ _unpack_tags( $^H{$class} ) } = ();
  delete @tags{ _unpack_tags(@_) };
  my $new = _pack_tags( keys %tags );
  if ( not length $new ) {
   delete $^H{$class};
  } else {
   $^H{$class} = $new;
  }
 } else {
  delete $^H{$class};
 }
 return;
}
}
package constant; BEGIN { $INC{"constant.pm"} = "constant.pm" }
BEGIN {
use strict;
use warnings::register;
use vars qw($VERSION %declared);
$VERSION = '1.17';
my %keywords = map +($_, 1), qw{ BEGIN INIT CHECK END DESTROY AUTOLOAD };
$keywords{UNITCHECK}++ if $] > 5.009;
my %forced_into_main = map +($_, 1),
 qw{ STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG };
my %forbidden = (%keywords, %forced_into_main);
sub import {
 my $class = shift;
 return unless @_;
 my $constants;
 my $multiple  = ref $_[0];
 my $pkg = caller;
 my $symtab;
 my $str_end = $] >= 5.006 ? "\\z" : "\\Z";
 if ($] > 5.009002) {
  no strict 'refs';
  $symtab = \%{$pkg . '::'};
 };
 if ( $multiple ) {
  if (ref $_[0] ne 'HASH') {
   Carp::croak("Invalid reference type '".ref(shift)."' not 'HASH'");
  }
  $constants = shift;
 } else {
  $constants->{+shift} = undef;
 }
 foreach my $name ( keys %$constants ) {
  unless (defined $name) {
   Carp::croak("Can't use undef as constant name");
  }
  if ($name =~ /^_?[^\W_0-9]\w*$str_end/ and !$forbidden{$name}) {
  } elsif ($forced_into_main{$name} and $pkg ne 'main') {
   Carp::croak("Constant name '$name' is forced into main::");
  } elsif ($name =~ /^__/) {
   Carp::croak("Constant name '$name' begins with '__'");
  } elsif ($name =~ /^[A-Za-z_]\w*$str_end/) {
   if (warnings::enabled()) {
    if ($keywords{$name}) {
     warnings::warn("Constant name '$name' is a Perl keyword");
    } elsif ($forced_into_main{$name}) {
     warnings::warn("Constant name '$name' is " .
      "forced into package main::");
    }
   }
  } elsif ($name =~ /^[01]?$str_end/) {
   if (@_) {
    Carp::croak("Constant name '$name' is invalid");
   } else {
    Carp::croak("Constant name looks like boolean value");
   }
  } else {
   Carp::croak("Constant name '$name' has invalid characters");
  }
  {
   no strict 'refs';
   my $full_name = "${pkg}::$name";
   $declared{$full_name}++;
   if ($multiple || @_ == 1) {
    my $scalar = $multiple ? $constants->{$name} : $_[0];
    if ($symtab && !exists $symtab->{$name}) {
     Internals::SvREADONLY($scalar, 1);
     $symtab->{$name} = \$scalar;
     mro::method_changed_in($pkg);
    } else {
     *$full_name = sub () { $scalar };
    }
   } elsif (@_) {
    my @list = @_;
    *$full_name = sub () { @list };
   } else {
    *$full_name = sub () { };
   }
  }
 }
}
}
package filetest; BEGIN { $INC{"filetest.pm"} = "filetest.pm" }
BEGIN {
$filetest::VERSION = '1.02';
$filetest::hint_bits = 0x00400000;
sub import {
 if ( $_[1] eq 'access' ) {
  $^H |= $filetest::hint_bits;
 } else {
  die "filetest: the only implemented subpragma is 'access'.\n";
 }
}
sub unimport {
 if ( $_[1] eq 'access' ) {
  $^H &= ~$filetest::hint_bits;
 } else {
  die "filetest: the only implemented subpragma is 'access'.\n";
 }
}
}
package overload; BEGIN { $INC{"overload.pm"} = "overload.pm" }
BEGIN {
$overload::VERSION = '1.07';
sub nil {}
sub OVERLOAD {
  $package = shift;
  my %arg = @_;
  my ($sub, $fb);
  $ {$package . "::OVERLOAD"}{dummy}++;
  *{$package . "::()"} = \&nil;
  for (keys %arg) {
 if ($_ eq 'fallback') {
   $fb = $arg{$_};
 } else {
   $sub = $arg{$_};
   if (not ref $sub and $sub !~ /::/) {
  $ {$package . "::(" . $_} = $sub;
  $sub = \&nil;
   }
   *{$package . "::(" . $_} = \&{ $sub };
 }
  }
  ${$package . "::()"} = $fb;
}
sub import {
  $package = (caller())[0];
  shift;
  $package->overload::OVERLOAD(@_);
}
sub unimport {
  $package = (caller())[0];
  ${$package . "::OVERLOAD"}{dummy}++;
  shift;
  for (@_) {
 if ($_ eq 'fallback') {
   undef $ {$package . "::()"};
 } else {
   delete $ {$package . "::"}{"(" . $_};
 }
  }
}
sub Overloaded {
  my $package = shift;
  $package = ref $package if ref $package;
  $package->can('()');
}
sub ov_method {
  my $globref = shift;
  return undef unless $globref;
  my $sub = \&{*$globref};
  return $sub if $sub ne \&nil;
  return shift->can($ {*$globref});
}
sub OverloadedStringify {
  my $package = shift;
  $package = ref $package if ref $package;
  ov_method mycan($package, '(""'), $package
 or ov_method mycan($package, '(0+'), $package
 or ov_method mycan($package, '(bool'), $package
 or ov_method mycan($package, '(nomethod'), $package;
}
sub Method {
  my $package = shift;
  if(ref $package) {
 local $@;
 local $!;
 require Scalar::Util;
 $package = Scalar::Util::blessed($package);
 return undef if !defined $package;
  }
  ov_method mycan($package, '(' . shift), $package;
}
sub AddrRef {
  my $package = ref $_[0];
  return "$_[0]" unless $package;
  local $@;
  local $!;
  require Scalar::Util;
  my $class = Scalar::Util::blessed($_[0]);
  my $class_prefix = defined($class) ? "$class=" : "";
  my $type = Scalar::Util::reftype($_[0]);
  my $addr = Scalar::Util::refaddr($_[0]);
  return sprintf("$class_prefix$type(0x%x)", $addr);
}
*StrVal = *AddrRef;
sub mycan {
  my ($package, $meth) = @_;
  my $mro = mro::get_linear_isa($package);
  foreach my $p (@$mro) {
 my $fqmeth = $p . q{::} . $meth;
 return \*{$fqmeth} if defined &{$fqmeth};
  }
  return undef;
}
%constants = (
     'integer'   =>  0x1000,
     'float'   =>  0x2000,
     'binary'   =>  0x4000,
     'q'   =>  0x8000,
     'qr'   => 0x10000,
    );
%ops = ( with_assign   => "+ - * / % ** << >> x .",
   assign    => "+= -= *= /= %= **= <<= >>= x= .=",
   num_comparison   => "< <= >  >= == !=",
   '3way_comparison'=> "<=> cmp",
   str_comparison   => "lt le gt ge eq ne",
   binary    => '& &= | |= ^ ^=',
   unary    => "neg ! ~",
   mutators   => '++ --',
   func    => "atan2 cos sin exp abs log sqrt int",
   conversion   => 'bool "" 0+',
   iterators   => '<>',
   dereferencing   => '${} @{} %{} &{} *{}',
   matching   => '~~',
   special   => 'nomethod fallback =');
use warnings::register;
sub constant {
  while (@_) {
 if (@_ == 1) {
  warnings::warnif ("Odd number of arguments for overload::constant");
  last;
 } elsif (!exists $constants {$_ [0]}) {
  warnings::warnif ("`$_[0]' is not an overloadable type");
 } elsif (!ref $_ [1] || "$_[1]" !~ /(^|=)CODE\(0x[0-9a-f]+\)$/) {
  if (warnings::enabled) {
   $_ [1] = "undef" unless defined $_ [1];
   warnings::warn ("`$_[1]' is not a code reference");
  }
 } else {
  $^H{$_[0]} = $_[1];
  $^H |= $constants{$_[0]};
 }
 shift, shift;
  }
}
sub remove_constant {
  while (@_) {
 delete $^H{$_[0]};
 $^H &= ~ $constants{$_[0]};
 shift, shift;
  }
}
}
package English; BEGIN { $INC{"English.pm"} = "English.pm" }
BEGIN {
$English::VERSION = '1.04';
@ISA = qw(Exporter);
no warnings;
my $globbed_match ;
sub import {
 my $this = shift;
 my @list = grep { ! /^-no_match_vars$/ } @_ ;
 local $Exporter::ExportLevel = 1;
 if ( @_ == @list ) {
  *EXPORT = \@COMPLETE_EXPORT ;
  $globbed_match ||= (
   eval q{
    *MATCH    = *& ;
    *PREMATCH   = *` ;
    *POSTMATCH   = *' ;
    1 ;
      }
   || do {
    Carp::croak("Can't create English for match leftovers: $@") ;
   }
  ) ;
 } else {
  *EXPORT = \@MINIMAL_EXPORT ;
 }
 Exporter::import($this,grep {s/^\$/*/} @list);
}
@MINIMAL_EXPORT = qw(
  *ARG
  *LAST_PAREN_MATCH
  *INPUT_LINE_NUMBER
  *NR
  *INPUT_RECORD_SEPARATOR
  *RS
  *OUTPUT_AUTOFLUSH
  *OUTPUT_FIELD_SEPARATOR
  *OFS
  *OUTPUT_RECORD_SEPARATOR
  *ORS
  *LIST_SEPARATOR
  *SUBSCRIPT_SEPARATOR
  *SUBSEP
  *FORMAT_PAGE_NUMBER
  *FORMAT_LINES_PER_PAGE
  *FORMAT_LINES_LEFT
  *FORMAT_NAME
  *FORMAT_TOP_NAME
  *FORMAT_LINE_BREAK_CHARACTERS
  *FORMAT_FORMFEED
  *CHILD_ERROR
  *OS_ERROR
  *ERRNO
  *EXTENDED_OS_ERROR
  *EVAL_ERROR
  *PROCESS_ID
  *PID
  *REAL_USER_ID
  *UID
  *EFFECTIVE_USER_ID
  *EUID
  *REAL_GROUP_ID
  *GID
  *EFFECTIVE_GROUP_ID
  *EGID
  *PROGRAM_NAME
  *PERL_VERSION
  *ACCUMULATOR
  *COMPILING
  *DEBUGGING
  *SYSTEM_FD_MAX
  *INPLACE_EDIT
  *PERLDB
  *BASETIME
  *WARNING
  *EXECUTABLE_NAME
  *OSNAME
  *LAST_REGEXP_CODE_RESULT
  *EXCEPTIONS_BEING_CAUGHT
  *LAST_SUBMATCH_RESULT
  @LAST_MATCH_START
  @LAST_MATCH_END
);
@MATCH_EXPORT = qw(
  *MATCH
  *PREMATCH
  *POSTMATCH
);
@COMPLETE_EXPORT = ( @MINIMAL_EXPORT, @MATCH_EXPORT ) ;
  *ARG     = *_ ;
 #*LAST_PAREN_MATCH   = *+ ;
  *LAST_SUBMATCH_RESULT   = *^N ;
 #*LAST_MATCH_START   = *-{ARRAY} ;
 #*LAST_MATCH_END    = *+{ARRAY} ;
  *INPUT_LINE_NUMBER   = *. ;
   *NR     = *. ;
  *INPUT_RECORD_SEPARATOR   = */ ;
   *RS     = */ ;
  *OUTPUT_AUTOFLUSH   = *| ;
  *OUTPUT_FIELD_SEPARATOR   = *, ;
   *OFS    = *, ;
  *OUTPUT_RECORD_SEPARATOR  = *\ ;
   *ORS    = *\ ;
  *LIST_SEPARATOR    = *" ;
  *SUBSCRIPT_SEPARATOR   = *; ;
   *SUBSEP    = *; ;
  *FORMAT_PAGE_NUMBER   = *% ;
  *FORMAT_LINES_PER_PAGE   = *= ;
 #*FORMAT_LINES_LEFT   = *- ;
  *FORMAT_NAME    = *~ ;
  *FORMAT_TOP_NAME   = *^ ;
  *FORMAT_LINE_BREAK_CHARACTERS  = *: ;
  *FORMAT_FORMFEED   = *^L ;
  *CHILD_ERROR    = *? ;
  *OS_ERROR    = *! ;
   *ERRNO    = *! ;
  *OS_ERROR    = *! ;
   *ERRNO    = *! ;
  *EXTENDED_OS_ERROR   = *^E ;
  *EVAL_ERROR    = *@ ;
  *PROCESS_ID    = *$ ;
   *PID    = *$ ;
  *REAL_USER_ID    = *< ;
   *UID    = *< ;
  *EFFECTIVE_USER_ID   = *> ;
   *EUID    = *> ;
  *REAL_GROUP_ID    = *( ;
   *GID    = *( ;
  *EFFECTIVE_GROUP_ID   = *) ;
   *EGID    = *) ;
  *PROGRAM_NAME    = *0 ;
  *PERL_VERSION    = *^V ;
  *ACCUMULATOR    = *^A ;
  *COMPILING    = *^C ;
  *DEBUGGING    = *^D ;
  *SYSTEM_FD_MAX    = *^F ;
  *INPLACE_EDIT    = *^I ;
  *PERLDB     = *^P ;
  *LAST_REGEXP_CODE_RESULT  = *^R ;
  *EXCEPTIONS_BEING_CAUGHT  = *^S ;
  *BASETIME    = *^T ;
  *WARNING    = *^W ;
  *EXECUTABLE_NAME   = *^X ;
  *OSNAME     = *^O ;
  *ARRAY_BASE    = *[ ;
  *OFMT     = *# ;
  *OLD_PERL_VERSION   = *] ;
 #*"
}
package feature; BEGIN { $INC{"feature.pm"} = "feature.pm" }
BEGIN {
$feature::VERSION = '1.13';
my %feature = (
 switch => 'feature_switch',
 say    => "feature_say",
 state  => "feature_state",
);
my %feature_bundle = (
 "5.10" => [qw(switch say state)],
);
$feature_bundle{"5.9.5"} = $feature_bundle{"5.10"};
sub import {
 my $class = shift;
 if (@_ == 0) {
  croak("No features specified");
 }
 while (@_) {
  my $name = shift(@_);
  if (substr($name, 0, 1) eq ":") {
   my $v = substr($name, 1);
   if (!exists $feature_bundle{$v}) {
    $v =~ s/^([0-9]+)\.([0-9]+).[0-9]+$/$1.$2/;
    if (!exists $feature_bundle{$v}) {
     unknown_feature_bundle(substr($name, 1));
    }
   }
   unshift @_, @{$feature_bundle{$v}};
   next;
  }
  if (!exists $feature{$name}) {
   unknown_feature($name);
  }
  $^H{$feature{$name}} = 1;
 }
}
sub unimport {
 my $class = shift;
 if (!@_) {
  delete @^H{ values(%feature) };
  return;
 }
 while (@_) {
  my $name = shift;
  if (substr($name, 0, 1) eq ":") {
   my $v = substr($name, 1);
   if (!exists $feature_bundle{$v}) {
    $v =~ s/^([0-9]+)\.([0-9]+).[0-9]+$/$1.$2/;
    if (!exists $feature_bundle{$v}) {
     unknown_feature_bundle(substr($name, 1));
    }
   }
   unshift @_, @{$feature_bundle{$v}};
   next;
  }
  if (!exists($feature{$name})) {
   unknown_feature($name);
  } else {
   delete $^H{$feature{$name}};
  }
 }
}
sub unknown_feature {
 my $feature = shift;
 croak(sprintf('Feature "%s" is not supported by Perl %vd',
   $feature, $^V));
}
sub unknown_feature_bundle {
 my $feature = shift;
 croak(sprintf('Feature bundle "%s" is not supported by Perl %vd',
   $feature, $^V));
}
sub croak {
 Carp::croak(@_);
}
}
package sort; BEGIN { $INC{"sort.pm"} = "sort.pm" }
BEGIN {
$sort::VERSION = '2.01';
$sort::quicksort_bit   = 0x00000001;
$sort::mergesort_bit   = 0x00000002;
$sort::sort_bits       = 0x000000FF;
$sort::stable_bit      = 0x00000100;
use strict;
sub import {
 shift;
 if (@_ == 0) {
  Carp::croak("sort pragma requires arguments");
 }
 local $_;
 $^H{sort} //= 0;
 while ($_ = shift(@_)) {
  if (/^_q(?:uick)?sort$/) {
   $^H{sort} &= ~$sort::sort_bits;
   $^H{sort} |=  $sort::quicksort_bit;
  } elsif ($_ eq '_mergesort') {
   $^H{sort} &= ~$sort::sort_bits;
   $^H{sort} |=  $sort::mergesort_bit;
  } elsif ($_ eq 'stable') {
   $^H{sort} |=  $sort::stable_bit;
  } elsif ($_ eq 'defaults') {
   $^H{sort} =   0;
  } else {
   Carp::croak("sort: unknown subpragma '$_'");
  }
 }
}
sub unimport {
 shift;
 if (@_ == 0) {
  Carp::croak("sort pragma requires arguments");
 }
 local $_;
 no warnings 'uninitialized';
 while ($_ = shift(@_)) {
  if (/^_q(?:uick)?sort$/) {
   $^H{sort} &= ~$sort::sort_bits;
  } elsif ($_ eq '_mergesort') {
   $^H{sort} &= ~$sort::sort_bits;
  } elsif ($_ eq 'stable') {
   $^H{sort} &= ~$sort::stable_bit;
  } else {
   Carp::croak("sort: unknown subpragma '$_'");
  }
 }
}
sub current {
 my @sort;
 if ($^H{sort}) {
  push @sort, 'quicksort' if $^H{sort} & $sort::quicksort_bit;
  push @sort, 'mergesort' if $^H{sort} & $sort::mergesort_bit;
  push @sort, 'stable'    if $^H{sort} & $sort::stable_bit;
 }
 push @sort, 'mergesort' unless @sort;
 join(' ', @sort);
}
}
package UNIVERSAL; BEGIN { $INC{"UNIVERSAL.pm"} = "UNIVERSAL.pm" }
BEGIN {
$UNIVERSAL::VERSION = '1.05';
@EXPORT_OK = qw(isa can VERSION);
sub import {
 return unless $_[0] eq __PACKAGE__;
 goto &Exporter::import;
}
}
package open; BEGIN { $INC{"open.pm"} = "open.pm" }
BEGIN {
$open::VERSION = '1.07';
my $locale_encoding;
sub _get_encname {
 return ($1, Encode::resolve_alias($1)) if $_[0] =~ /^:?encoding\((.+)\)$/;
 return;
}
sub croak {
 goto &Carp::croak;
}
sub _drop_oldenc {
 my ($h, @new) = @_;
 return unless @new >= 1 && $new[-1] =~ /^:encoding\(.+\)$/;
 my @old = PerlIO::get_layers($h);
 return unless @old >= 3 &&
      $old[-1] eq 'utf8' &&
      $old[-2] =~ /^encoding\(.+\)$/;
 require Encode;
 my ($loname, $lcname) = _get_encname($old[-2]);
 unless (defined $lcname) {
  croak("open: Unknown encoding '$loname'");
 }
 my ($voname, $vcname) = _get_encname($new[-1]);
 unless (defined $vcname) {
  croak("open: Unknown encoding '$voname'");
 }
 if ($lcname eq $vcname) {
  binmode($h, ":pop");
 }
}
sub import {
 my ($class,@args) = @_;
 croak("open: needs explicit list of PerlIO layers") unless @args;
 my $std;
 my ($in,$out) = split(/\0/,(${^OPEN} || "\0"), -1);
 while (@args) {
  my $type = shift(@args);
  my $dscp;
  if ($type =~ /^:?(utf8|locale|encoding\(.+\))$/) {
   $type = 'IO';
   $dscp = ":$1";
  } elsif ($type eq ':std') {
   $std = 1;
   next;
  } else {
   $dscp = shift(@args) || '';
  }
  my @val;
  foreach my $layer (split(/\s+/,$dscp)) {
   $layer =~ s/^://;
   if ($layer eq 'locale') {
    require Encode;
    require encoding;
    $locale_encoding = encoding::_get_locale_encoding()
     unless defined $locale_encoding;
    (warnings::warnif("layer", "Cannot figure out an encoding to use"), last)
     unless defined $locale_encoding;
    $layer = "encoding($locale_encoding)";
    $std = 1;
   } else {
    my $target = $layer;
    $target =~ s/^(\w+)\(.+\)$/$1/;
    unless(PerlIO::Layer::->find($target,1)) {
     warnings::warnif("layer", "Unknown PerlIO layer '$target'");
    }
   }
   push(@val,":$layer");
   if ($layer =~ /^(crlf|raw)$/) {
    $^H{"open_$type"} = $layer;
   }
  }
  if ($type eq 'IN') {
   _drop_oldenc(*STDIN, @val);
   $in  = join(' ', @val);
  } elsif ($type eq 'OUT') {
   _drop_oldenc(*STDOUT, @val);
   $out = join(' ', @val);
  } elsif ($type eq 'IO') {
   _drop_oldenc(*STDIN,  @val);
   _drop_oldenc(*STDOUT, @val);
   $in = $out = join(' ', @val);
  } else {
   croak "Unknown PerlIO layer class '$type'";
  }
 }
 ${^OPEN} = join("\0", $in, $out);
 if ($std) {
  if ($in) {
   if ($in =~ /:utf8\b/) {
     binmode(STDIN,  ":utf8");
    } elsif ($in =~ /(\w+\(.+\))/) {
     binmode(STDIN,  ":$1");
    }
  }
  if ($out) {
   if ($out =~ /:utf8\b/) {
    binmode(STDOUT,  ":utf8");
    binmode(STDERR,  ":utf8");
   } elsif ($out =~ /(\w+\(.+\))/) {
    binmode(STDOUT,  ":$1");
    binmode(STDERR,  ":$1");
   }
  }
 }
}
}
package NEXT; BEGIN { $INC{"NEXT.pm"} = "NEXT.pm" }
BEGIN {
$VERSION = '0.64';
use Carp;
use strict;
use overload ();
sub NEXT::ELSEWHERE::ancestors
{
  my @inlist = shift;
  my @outlist = ();
  while (my $next = shift @inlist) {
    push @outlist, $next;
    no strict 'refs';
    unshift @inlist, @{"$outlist[-1]::ISA"};
  }
  return @outlist;
}
sub NEXT::ELSEWHERE::ordered_ancestors
{
  my @inlist = shift;
  my @outlist = ();
  while (my $next = shift @inlist) {
    push @outlist, $next;
    no strict 'refs';
    push @inlist, @{"$outlist[-1]::ISA"};
  }
  return sort { $a->isa($b) ? -1
     : $b->isa($a) ? +1
     :                0 } @outlist;
}
sub NEXT::ELSEWHERE::buildAUTOLOAD
{
 my $autoload_name = caller() . '::AUTOLOAD';
 no strict 'refs';
 *{$autoload_name} = sub {
  my ($self) = @_;
  my $depth = 1;
  until (((caller($depth))[3]||q{}) !~ /^\(eval\)$/) { $depth++ }
  my $caller = (caller($depth))[3];
  my $wanted = $NEXT::AUTOLOAD || $autoload_name;
  undef $NEXT::AUTOLOAD;
  my ($caller_class, $caller_method) = do { $caller =~ m{(.*)::(.*)}g };
  my ($wanted_class, $wanted_method) = do { $wanted =~ m{(.*)::(.*)}g };
  croak "Can't call $wanted from $caller"
   unless $caller_method eq $wanted_method;
  my $key = ref $self && overload::Overloaded($self)
   ? overload::StrVal($self) : $self;
  local ($NEXT::NEXT{$key,$wanted_method}, $NEXT::SEEN) =
   ($NEXT::NEXT{$key,$wanted_method}, $NEXT::SEEN);
  unless ($NEXT::NEXT{$key,$wanted_method}) {
   my @forebears =
    NEXT::ELSEWHERE::ancestors ref $self || $self,
       $wanted_class;
   while (@forebears) {
    last if shift @forebears eq $caller_class
   }
   no strict 'refs';
   @{$NEXT::NEXT{$key,$wanted_method}} =
    map {
     my $stash = \%{"${_}::"};
     ($stash->{$caller_method} && (*{$stash->{$caller_method}}{CODE}))
      ? *{$stash->{$caller_method}}{CODE}
      : () } @forebears
     unless $wanted_method eq 'AUTOLOAD';
   @{$NEXT::NEXT{$key,$wanted_method}} =
    map {
     my $stash = \%{"${_}::"};
     ($stash->{AUTOLOAD} && (*{$stash->{AUTOLOAD}}{CODE}))
      ? "${_}::AUTOLOAD"
      : () } @forebears
     unless @{$NEXT::NEXT{$key,$wanted_method}||[]};
   $NEXT::SEEN->{$key,*{$caller}{CODE}}++;
  }
  my $call_method = shift @{$NEXT::NEXT{$key,$wanted_method}};
  while (do { $wanted_class =~ /^NEXT\b.*\b(UNSEEN|DISTINCT)\b/ }
   && defined $call_method
   && $NEXT::SEEN->{$key,$call_method}++) {
   $call_method = shift @{$NEXT::NEXT{$key,$wanted_method}};
  }
  unless (defined $call_method) {
   return unless do { $wanted_class =~ /^NEXT:.*:ACTUAL/ };
   (local $Carp::CarpLevel)++;
   croak qq(Can't locate object method "$wanted_method" ),
    qq(via package "$caller_class");
  };
  return $self->$call_method(@_[1..$#_]) if ref $call_method eq 'CODE';
  no strict 'refs';
  do { ($wanted_method=${$caller_class."::AUTOLOAD"}) =~ s/.*::// }
   if $wanted_method eq 'AUTOLOAD';
  $$call_method = $caller_class."::NEXT::".$wanted_method;
  return $call_method->(@_);
 };
}
no strict 'vars';
 package NEXT;                                  NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::UNSEEN;  @ISA = 'NEXT';     NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::DISTINCT;  @ISA = 'NEXT';     NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::ACTUAL;  @ISA = 'NEXT';     NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::ACTUAL::UNSEEN; @ISA = 'NEXT'; NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::ACTUAL::DISTINCT; @ISA = 'NEXT'; NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::UNSEEN::ACTUAL; @ISA = 'NEXT'; NEXT::ELSEWHERE::buildAUTOLOAD();
 package NEXT::DISTINCT::ACTUAL; @ISA = 'NEXT'; NEXT::ELSEWHERE::buildAUTOLOAD();
 package EVERY;
sub EVERY::ELSEWHERE::buildAUTOLOAD {
 my $autoload_name = caller() . '::AUTOLOAD';
 no strict 'refs';
 *{$autoload_name} = sub {
  my ($self) = @_;
  my $depth = 1;
  until (((caller($depth))[3]||q{}) !~ /^\(eval\)$/) { $depth++ }
  my $caller = (caller($depth))[3];
  my $wanted = $EVERY::AUTOLOAD || $autoload_name;
  undef $EVERY::AUTOLOAD;
  my ($wanted_class, $wanted_method) = do { $wanted =~ m{(.*)::(.*)}g };
  my $key = ref($self) && overload::Overloaded($self)
   ? overload::StrVal($self) : $self;
  local $NEXT::ALREADY_IN_EVERY{$key,$wanted_method} =
   $NEXT::ALREADY_IN_EVERY{$key,$wanted_method};
  return if $NEXT::ALREADY_IN_EVERY{$key,$wanted_method}++;
  my @forebears = NEXT::ELSEWHERE::ordered_ancestors ref $self || $self,
          $wanted_class;
  @forebears = reverse @forebears if do { $wanted_class =~ /\bLAST\b/ };
  no strict 'refs';
  my %seen;
  my @every = map { my $sub = "${_}::$wanted_method";
     !*{$sub}{CODE} || $seen{$sub}++ ? () : $sub
     } @forebears
     unless $wanted_method eq 'AUTOLOAD';
  my $want = wantarray;
  if (@every) {
   if ($want) {
    return map {($_, [$self->$_(@_[1..$#_])])} @every;
   } elsif (defined $want) {
    return { map {($_, scalar($self->$_(@_[1..$#_])))}
      @every
     };
   } else {
    $self->$_(@_[1..$#_]) for @every;
    return;
   }
  }
  @every = map { my $sub = "${_}::AUTOLOAD";
    !*{$sub}{CODE} || $seen{$sub}++ ? () : "${_}::AUTOLOAD"
    } @forebears;
  if ($want) {
   return map { $$_ = ref($self)."::EVERY::".$wanted_method;
     ($_, [$self->$_(@_[1..$#_])]);
    } @every;
  } elsif (defined $want) {
   return { map { $$_ = ref($self)."::EVERY::".$wanted_method;
     ($_, scalar($self->$_(@_[1..$#_])))
     } @every
    };
  } else {
   for (@every) {
    $$_ = ref($self)."::EVERY::".$wanted_method;
    $self->$_(@_[1..$#_]);
   }
   return;
  }
 };
}
 package EVERY::LAST;   @ISA = 'EVERY';   EVERY::ELSEWHERE::buildAUTOLOAD();
 package EVERY;         @ISA = 'NEXT';    EVERY::ELSEWHERE::buildAUTOLOAD();
}
BEGIN {
if (defined &File::Glob::bootstrap) {
# miniperl doesn't have File::Glob::botstrap, so it implements glob("*") by
# calling /bin/sh echo * as a workaround.
package File::Glob; BEGIN { $INC{"File/Glob.pm"} = "File/Glob.pm"; }
use strict;
our($VERSION, @ISA, @EXPORT_OK, @EXPORT_FAIL, %EXPORT_TAGS, $AUTOLOAD, $DEFAULT_FLAGS);
@ISA = qw(Exporter);
@EXPORT_OK = qw(bsd_glob glob GLOB_ABEND GLOB_ALPHASORT GLOB_ALTDIRFUNC
GLOB_BRACE GLOB_CSH GLOB_ERR GLOB_ERROR GLOB_LIMIT GLOB_MARK GLOB_NOCASE
GLOB_NOCHECK GLOB_NOMAGIC GLOB_NOSORT GLOB_NOSPACE GLOB_QUOTE GLOB_TILDE);
%EXPORT_TAGS = ('glob' => [qw(GLOB_ABEND GLOB_ALPHASORT GLOB_ALTDIRFUNC
GLOB_BRACE GLOB_CSH GLOB_ERR GLOB_ERROR GLOB_LIMIT GLOB_MARK GLOB_NOCASE
GLOB_NOCHECK GLOB_NOMAGIC GLOB_NOSORT GLOB_NOSPACE GLOB_QUOTE GLOB_TILDE
glob bsd_glob)]);
$VERSION = '1.06';
sub import {
  # Segfault without this.
  *CORE::GLOBAL::glob = \&File::Glob::csh_glob if 0;
  require Exporter;
  my $i = 1;
  while ($i < @_) {
    if ($_[$i] =~ /^:(case|nocase|globally)$/) {
      splice(@_, $i, 1);
      $DEFAULT_FLAGS &= ~GLOB_NOCASE() if $1 eq 'case';
      $DEFAULT_FLAGS |= GLOB_NOCASE() if $1 eq 'nocase';
      die "unsupported: globally\n" if $1 eq 'globally';
      next;
    }
    ++$i;
  }
  goto &Exporter::import;
}
# Defines doglob, constant.
File::Glob::bootstrap($VERSION);
{
  # E.g. GLOB_ABEND.
  for my $name (@EXPORT_OK) {
    my ($error, $val) = constant($name);
    eval "sub $name { $val }" if !$error;
  }
}
sub GLOB_CSH() {
  GLOB_BRACE() | GLOB_NOMAGIC() | GLOB_QUOTE() | GLOB_TILDE() | GLOB_ALPHASORT()
}
$DEFAULT_FLAGS = GLOB_CSH();
sub bsd_glob {
  my ($pat,$flags) = @_;
  $flags = $DEFAULT_FLAGS if @_ < 2;
  return doglob($pat,$flags);
}
sub glob {
  splice @_, 1;
  goto &bsd_glob;
}
}
}
BEGIN {
if (defined &Cwd::bootstrap) {
# miniperl doesn't have Cwd::bootstrap, so it doesn't provide cwd
# functionality.
package Cwd; BEGIN { $INC{"Cwd.pm"} = "Cwd.pm" }
use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
$VERSION = 3.30;
@ISA = qw(Exporter);
@EXPORT = qw(cwd getcwd fastcwd fastgetcwd);
@EXPORT_OK = qw(chdir abs_path realpath fast_realpath);
Cwd::bootstrap("$VERSION");
*cwd = \&getcwd;
*fastgetcwd = \&getcwd;
*realpath = \&abs_path;
# Keeps track of current working directory in PWD environment var
# Usage: use Cwd 'chdir'; chdir $newdir;
my $chdir_init = 0;
sub chdir_init {
  if ($ENV{'PWD'}) {
    my($dd,$di) = stat('.');
    my($pd,$pi) = stat($ENV{'PWD'});
    if (!defined $dd or !defined $pd or $di != $pi or $dd != $pd) {
      $ENV{'PWD'} = cwd();
    }
  } else {
    my $wd = cwd();
    $ENV{'PWD'} = $wd;
  }
  # Strip an automounter prefix (where /tmp_mnt/foo/bar == /foo/bar)
  if ($ENV{'PWD'} =~ m|(/[^/]+(/[^/]+/[^/]+))(.*)|s) {
    my($pd,$pi) = stat($2);
    my($dd,$di) = stat($1);
    if (defined $pd and defined $dd and $di == $pi and $dd == $pd) {
      $ENV{'PWD'}="$2$3";
    }
  }
  $chdir_init = 1;
}
sub chdir {
  # Allow for no arg (chdir to HOME dir).
  my $newdir = @_ ? shift : '';
  $newdir =~ s|///*|/|g unless $^O eq 'MSWin32';
  chdir_init() unless $chdir_init;
  my $newpwd;
  return 0 unless CORE::chdir $newdir;
  # In case a file/dir handle is passed in.
  if (ref $newdir eq 'GLOB') {
    $ENV{'PWD'} = cwd();
  } elsif ($newdir =~ m#^/#s) {
    $ENV{'PWD'} = $newdir;
  } else {
    my @curdir = split(m#/#,$ENV{'PWD'});
    @curdir = ('') unless @curdir;
    my $component;
    foreach $component (split(m#/#, $newdir)) {
      next if $component eq '.';
      pop(@curdir),next if $component eq '..';
      push(@curdir,$component);
    }
    $ENV{'PWD'} = join('/',@curdir) || '/';
  }
  1;
}
}
}
1;
