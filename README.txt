dosmc: C compiler driver to produce tiny DOS .exe and .com executables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
dosmc is a proof-of-concept C compiler driver for producing tiny DOS .exe
and .com executables for the 8086 (16-bit) architecture. It uses the wcc C
compiler in OpenWatcom V2, and it has its own C library (libc) and custom
linker for tiny executable output.

Usage:

  $ ./download_openwatcom.sh  # Run only once.

  $ ./dosmc prog.c  # Creates prog.exe.

  $ ./dosmc -bt=com prog.c  # Creates prog.com.

To try it, run `dosbox .' (without the quotes), and within the DOSBox
window, run prog.exe or prog.com . The expected output is `ZYfghiHello!'
(without the quotes).

If you want to write tiny DOS .exe and .com executables in assembly instead,
see http://github.com/pts/pts-nasm-fullprog

If you want to write tiny Linux i386 executables in C instead, see
http://github.com/pts/pts-xtiny

dosmc limitations:

* Build system must be Linux i386 or amd64. (It's possible to make it work
  on other Unix systems on which wcc and wdis are available.)
* It depends on Perl (standard packages only).
* It depends on the wcc C compiler in OpenWatcom V2.
* It depends on the wdis disassembler in OpenWatcom V2. This dependency will be
  removed in the future.
* It depends on nasm (NASM, Netwide Assembler). This dependency will be
  removed in the future.
* Target is DOS 8086 (16-bit) .exe or DOS 8086 (16-bit) .com.
* Only 2 memory models are supported: tiny for .com executables (maximum
  size of code + data + stack is ~63 KiB), and small for .exe executables
  (maximum size of code is ~64 KiB, maximum size of data + stack is ~64
  KiB).
* Only a single .c source file is supported, no additional source files or
  .obj or .lib files.
* The supplied C library (libc) is very limited, currently it doesn't
  contain much more than getchar and putchar. For most functionality,
  inline assembly with DOS calls (int 21h) should be used.
* There is no convenient way yet to get the command-line arguments and the
  environment.
* There is no stack overflow detector.
* It can't generate debug info.
* There is no convenient way to use more than 64 KiB of data, because the C
  library doesn't have functions which take far pointers.
* It doesn't support code longer than 64 KiB.
* It doesn't support 32-bit (i386) code or DOS extenders.
* It doesn't pass command-line arguments to main (always argc=0 argv=NULL).
  This will be fixed in the future.

dosmc advantages over wcc and owcc in OpenWatcom:

* dosmc generates a tiny .exe header, without explicit relocations.
* dosmc doesn't add several KiB of C library bloat.
* dosmc doesn't align data to word bounary, thus the executable becomes
  smaller.
* dosmc uses the wcc command-line flags to generate small output by
  default.

__END__
