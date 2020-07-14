/*
 * hello.c: typical standard C hello-world
 * by pts@fazekas.hu at Wed Jul 15 00:00:20 CEST 2020
 *
 * Build: ./dosmc examples/hello0.c
 *
 * Then run `dosbox examples', and within the DOSBox window, run hello0.exe .
 *
 * dosmc can generate a smaller hellow-world executable by making these
 * changes (see examples/hello.c):
 *
 * * Use _start() instead of main(). (This saves 114 bytes of argv
 *   parsing code. Also, main() without arguments is almost that good.)
 * * Build a .com file instead of an .exe file (dosmc -mt).
 * * Use _printmsgx instead of puts.
 */

#include <stdio.h>

int main(int argc, char **argv) {
  (void)argc; (void)argv;
  puts("Hello, World!");
  return 0;
}
