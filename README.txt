dosmc: C compiler and assembler to produce tiny DOS .exe and .com executables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
dosmc is a C compiler, assembler, linker and librarian for producing tiny
DOS .exe and .com executables for the 8086 (16-bit) architecture. It
contains and uses the wcc C compiler in OpenWatcom V2 and also NASM, and it
has its own C library (libc) and custom optimizing linker for tiny
executable output.

Download on Linux and macOS:

  $ git clone --depth 1 https://github.com/pts/dosmc
  $ cd dosmc
  $ ./dosmc --prepare  # Download executables, set up Docker image if needed.

Alternatively, if you don't have Git installed, you can download and extract
https://github.com/pts/dosmc/archive/master.zip instead.

Usage:

  $ ./dosmc examples/prog.c  # Creates examples/prog.exe .

  $ ./dosmc -mt examples/prog.c  # Creates examples/prog.com .

To try it, run `dosbox examples' (without the quotes), and within the DOSBox
window, run prog.exe or prog.com . The expected output is `ZYfghiHello!'
(without the quotes).

dosmc is an acronym for Deterministic Optimizing Small Model Compiler, where
``small model'' signifies the 16-bit pointer size and the resulting 64 KiB
memory limits (of the executable). The prefix DOS also refers to the
target system (MS-DOS and compatible, including DOSBox and FreeDOS).

dosmc is a cross-compiler: you can run it on a modern (32-bit or 64-bit)
host system to produce 16-bit DOS executables.

If you want to write tiny DOS .exe and .com executables in assembly instead,
see http://github.com/pts/pts-nasm-fullprog

If you want to write tiny Linux i386 executables in C instead, see
http://github.com/pts/pts-xtiny

dosmc limitations:

* Host build system must be Linux i386, Linux amd64 or macOS. On macOS,
  Docker needs to be installed first. (It's possible to make it
  work on other Unix systems on which wcc is available.) Porting to Windows
  (Win32) is underday, proof-of-concept compilation already works. Porting to
  FreeBSD should be easy (with Linux compatibility `kldload linux').
  Porting to DOS (32-bit, with DOS extenders) may work, but we need Perl
  first: https://perldoc.perl.org/perldos.html , also Perl 5.8.8 has been
  ported: https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.2/repos/pkg-html/perl.html
  . Other host systems are unlikely to work, because OpenWatcom hasn't been
  ported to them.
* It depends on Perl (standard packages only).
* It depends on the wcc C compiler in OpenWatcom V2.
* Target is DOS 8086 (16-bit) .exe or DOS 8086 (16-bit) .com.
* Only 2 memory models are supported: tiny for .com executables (maximum
  size of code + data + stack is ~63 KiB), and small for .exe executables
  (maximum size of code is ~64 KiB, maximum size of data + stack is ~64
  KiB).
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
* It's not possible to run the compilation on DOS yet. To make it happen,
  the dosmc shell script (and its substantial Perl code for linking) has
  to be rewritten in C, and the DOS version of wcc.exe from OpenWatcom V2
  (uses the DOS extender DOS/4GW) can be used.
* malloc() or dynamic memory allocation isn't provided, you have to
  preallocate global arrays to emulate it.
* Dynamic linking (.dll, .so, shared libraries) is not possible. This is an
  OpenWatcom limitation for DOS targets.

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
for that in the OpenWatcom C language. Alternatively, you can use entire
.asm files as sources (see some in the examples/ directory), in either NASM
or WASM syntax.

Source file formats:

* If the extension is .c, then the bundled wcc (OpenWatcom C compiler) is
  used to create the .obj file (in OMF format).
* If the extension is .nasm, then the bundled NASM 0.99.06 is used to create
  the .obj file. NASM is recommended or WASM for writing assembly code,
  because of the versatily and the clean syntax. dosmc also provides
  some convenience macros (e.g. __LINKER_FLAG) and defaults, see how compact
  examples/helloc.nasm is. (Also compare examples/helloc2.nasm
  o examples/helloc2w.wasm for compactness.) It's also possible to write
  your program in assembly only (no .c code), and use dosmc to compile it
  to .com or .exe, see examples/helloc.nasm for an example.
* If the extension is .wasm, then the bundled WASM (OpenWatcom assembler) is
  used to create the .obj file. Convenience macros are not provided.
* If the extension is .asm, then dosmc looks at the first directive in
  the file and autodetects it as .nasm or .wasm.
* If the extension is .obj, then the file is used as is for linking. The
  file format is DOS OMF .obj. Typical sources of .obj files: output of wcc
  (e.g. dosmc -c file.c), output of NASM (e.g. dosmc -c file.nasm),
  output of WASM (e.g. dosmc -c file.wasm), output of other assemblers
  (e.g. see examples/helloc2a.asm for MASM, TASM and A86; see
  examples/helloc2l.asm for LZASM). Most modern assemblers (e.g. YASM and
  FASM) can't create OMF .obj files, thus are incompatible with dosmc.
  NBASM uses a differnet sytnax, and we didn't managed to make it produce an
  .obj file, starting from examples/helloc2a.asm.
* If the extension is .lib, then the .obj modules stored in the specified
  static library are used as is for linking. `dosmc -cl' can be used to
  create a .lib file. .lib files created by other compilers and linkers
  will probably not work with dosmc. A .lib file is a concatenation of
  .obj files, with an extra header.

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
  DOS supports a command-line up to 127
  bytes (excluding argv[0], the program name). When parsing this, the
  dosmc C library splits on spaces and tab, ignoring quotes and backslashes.

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

The .com, .exe, .lib and .bin output files are deterministic (i.e. you get
the same output file if you compile the same input files again), but .obj
output isn't, because there is a timestamp in .obj files created by wcc (.c
source) and WASM (.wasm and maybe .asm source).

dosmc has a optimizing linker: if it encouters an .obj file which doesn't
define any symbols which are currently undefined, then it skips the entire
.obj file. If there are undefined symbols in the end, then it retries the
skipped .obj files, until all symbols become defined.

dosmc doesn't have a build system (such as GNU Make or CMake), but it's easy
use one if you write one in Perl. Just create a file named dosmcdir.pl next
to your source files, and run `./dosmc <directory>' to get it invoked with
the right $ENV{PATH}, @INC and @ARGV. $ARGV[0] will be the directory name.

dosmc has basic support for extension commands written in Perl. Write your
extension command as MYCMD.pl, save it to the same directory as dosmc's wcc
(preferred) or to the same directory as the dosmc Perl script, and invoke it
as `./dosmc MYCMD'. dosmc will sets $ENV{PATH}, @INC, @ARGV properly. If
it's inconvenient to save to these directories, then save the Perl script
anywhere, and specify the directory name in $ENV{DOSMCEXT}.

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
