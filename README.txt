dosmc: C compiler driver to produce tiny DOS .exe and .com executables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
dosmc is a proof-of-concept C compiler driver for producing tiny DOS .exe
and .com executables for the 8086 (16-bit) architecture. It uses the wcc C
compiler in OpenWatcom V2, and it has its own C library (libc) and custom
linker for tiny executable output.

Usage:

  $ ./download_openwatcom.sh  # Run only once.

  $ ./dosmc examples/prog.c  # Creates prog.exe.

  $ ./dosmc -mt examples/prog.c  # Creates prog.com.

To try it, run `dosbox examples' (without the quotes), and within the DOSBox
window, run prog.exe or prog.com . The expected output is `ZYfghiHello!'
(without the quotes).

If you want to write tiny DOS .exe and .com executables in assembly instead,
see http://github.com/pts/pts-nasm-fullprog

If you want to write tiny Linux i386 executables in C instead, see
http://github.com/pts/pts-xtiny

dosmc limitations:

* Build system must be Linux i386 or amd64. (It's possible to make it work
  on other Unix systems on which wcc is available.)
* It depends on Perl (standard packages only).
* It depends on the wcc C compiler in OpenWatcom V2.
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
* It's not possible to run the compilation on DOS yet. To make it happen,
  the dosmc shell script (and its substantial Perl code for linking) has
  to be rewritten in C, and the DOS version of wcc.exe from OpenWatcom V2
  (uses the DOS extender DOS/4GW) can be used.
* malloc() or dynamic memory allocation isn't provided, you have to
  preallocate global arrays to emulate it.

dosmc advantages over wcc and owcc in OpenWatcom:

* dosmc generates a tiny .exe header, without explicit relocations.
* dosmc doesn't add several KiB of C library bloat.
* dosmc doesn't align data to word bounary, thus the executable becomes
  smaller.
* dosmc uses the wcc command-line flags to generate small output by
  default.

It's possible to write inline assembly snippets in your C code using #pragma
aux (see dosmc.h for examples) and `__asm { ... }'. However, it's not
possible to write entire functions in assembly, because there is no syntax
for that in the OpenWatcom C language. Using entire .asm files as sources
doesn't work either with dosmc, because wcc cannot compile them (and wasm
is not included in dosmc).

Program entry points for dosmc (choose any):

* void _start(void) { ... }. Calling exit(0) in the end is optional.
  Command-line arguments are not parsed or passed. To get the least amount
  of file size overhead, use _start, use -mt if possible (to generate a .com
  file), make _start the very first function in the .c file (possibly
  predeclaring other functions), and have no global variables without
  initial value (in segment _BSS).
* int main(void) { ... }. Return exit code (0 means success).
  Command-line arguments are not parsed or passed.
* int main(int argc, char **argv) { ... }. Return exit code (0 means success).
  Command-line arguments are currently stubbed (argc=0, argv=NULL), will be
  parsed and passed in the future. DOS supports a command-line up to 127
  bytes (excluding argv[0], the program name). When parsing this, the
  dosmc C library splits on spaces and tab, except if the entire argument
  is double-quoted ("); it passes backslashes as is.

Global variables without initial value (e.g. `int myvar;') (in segment _BSS)
are auto-initialized to 0, stack isn't initialized.

What is the minimum executable file size dosmc can produce?

* For .com output, the theoretical minimum is 1 byte (`ret' instruction), and
  dosmc produces it for examples/exit0.c and examples/empty_start.c.
* For .exe output, the theoretical minimum is 28 bytes, because DOSBox
  refuses to load an .exe (without an error message) if it's shorter than 28
  bytes. The .exe header is 28 bytes, but the last 4 bytes are not used if
  there aren't any relocations. The shortest 8086 code to exit (for .exe
  files) is 5 bytes, so the minimum is 29 bytes, and dosmc produces it for
  examples/exit0.c, examples/exit42.c and examples/empty_start.c. It's
  possible to put the 5 bytes of code to the middle of the 28-byte .exe
  header at the expense of using 317 KiB of conventional memory, but dosmc
  doesn't waste that much.

How much overhead does dosmc add?

* For .com output, the overhead can be as low as 0 bytes, see
  examples/exit0.c, examples/exit42.c, examples/empty_start.c,
  examples/hello.c . For examples/hello.c, the output .com file is just 26
  bytes, 2 bytes more (because of `push dx' and `pop dx') than
  hand-optimized assembly.
* For .exe output, the overhead can be as low as 34 bytes (including the
  mandatory .exe header of 28 bytes). By some additional code mangling at
  link time to avoid the `call _start_' and the `ret', the 34 bytes could be
  decreased to 30 bytes.

Notes about maximum memory usage of DOS programs:

* 16-bit DOS programs can address up to 1 MiB memory (in real mode, using
  the segment * 16 + offset formula, where both segment and offset are
  16-bit), of which at most 640 KiB is available for programs (the rest is
  used by DOS device drivers, DOS, BIOS and video). Actually, due to DOS
  overhead, it's usually 600 KiB ... 635 KiB available on DOS systems (DOSBox
  typically: 632 KiB, FreeDOS typically: 616 KiB, and MS-DOS), and 512 KiB
  ... 600 KiB available in DOS mode of Windows systems.
* dosmc programs, just like other 16-bit DOS programs written in C using
  the small (.exe) or tiny (.com) memory model can access ~64 KiB of data
  conveniently. More specifically, tiny for .com executables (maximum
  size of code + data + stack is ~63 KiB), and small for .exe executables
  (maximum size of code is ~64 KiB, maximum size of data + stack is ~64
  KiB).
* It's possible to use far pointers in 16-bit DOS programs to access all the
  available memory below 1 MiB (i.e. >600 KiB), but that's inconvenient, it
  doesn't let us create single variables larger than 64 KiB, and doesn't
  have C library support in dosmc.
* 32-bit DOS programs (using DOS extenders, requiring i386 or newer CPU) can
  access several MiBs of memory. This even works in DOS mode of Windows and
  in many DOS emulators. OpenWatcom can compile C programs like this (see
  owcc commands below), but dosmc doesn't support this memory model, so
  you should use owcc directly. The price is that the .exe executable becomes
  larger (see below for typical minimum sizes). More specific limits:
  * DOSBox has a default limit of 16 MiB, which can be increased up to 63 MiB
    in the config file.
  * Some DOS extenders and host setups (clean, XMS, VCPI, DPMI) support up to
    64 MiB of memory, others support even more, e.g. 2 GiB, 3 GiB or almost
    4 GiB.
  * QEMU supports even more than 4 GiB of memory. FreeDOS 1.2 running in QEMU
    supports up to 3 GiB of memory. However this 3 GiB is further limited by
    the DOS extender used.
  * DOS extender DOS/4GW (`owcc -bdos4g' target) running in FreeDOS 1.2 in
    QEMU supports up to 64 MiB of memory (of which malloc() can allocate 62
    in 1 MiB chunks). The 64 MiB is an official limit, and it's unlikely
    to be increased. Minimum stripped (`owcc -s') executable size with
    malloc(), printf(), scanf() seems to be 24 KiB (+260 KiB for dos4gw.exe).
  * DOS extender WDOSX (`owcc -bdos4g' target, then running WDOSX' stubit.exe
    on the executable) running in FreeDOS 1.2 in QEMU supports up to 512 MiB
    of memory (of which malloc() can allocate 510 in 1 MiB chunks). The 512
    MiB limit is mentioned in wdosx097/SRC/DOC/README.TXT, and it's
    unlikely to be increased.
    Minimum stripped (`owcc -s') executable size with
    malloc(), printf(), scanf() seems to be 34 KiB.
  * DOS extender DOS/32A (`owcc -bdos32a' target) running in FreeDOS 1.2 in
    QEMU supports up to 2 GiB of memory (of which there is ~0.4414% overhead:
    malloc() can allocate 2039 in 1 MiB chunks).
    Minimum stripped (`owcc -s') executable size with
    malloc(), printf(), scanf() seems to be 51 KiB.

__END__
