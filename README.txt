dosmc: C compiler driver to produce tiny DOS .exe and .com executables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
dosmc is a proof-of-concept C compiler driver for producing tiny DOS .exe
and .com executables for the 8086 (16-bit) architecture. It uses the wcc C
compiler in OpenWatcom V2, and it has its own C library (libc) and custom
linker for tiny executable output.

If you want to write tiny DOS .exe and .com executables in assembly instead,
see http://github.com/pts/pts-nasm-fullprog

Usage:

  $ ./download_openwatcom.sh  # Run only once.

  $ ./dosmc prog.c  # Creates prog.exe.

  $ ./owccods -bt=com prog.c  # Creates prog.com.

To try it, run `dosbox .' (without the quotes), and within the DOSBox
window, run prog.exe or prog.com . The expected output is `ZYfghiHello!'
(without the quotes).

dosmc limitations:

* Build system must be Linux i386 or amd64.
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
* The supplied C library (libc) is very limited. For most functionality,
  inline assembly with DOS calls (int 21h) should be used.
* There is no convenient way yet to get the command-line arguments and the
  environment.

__END__
