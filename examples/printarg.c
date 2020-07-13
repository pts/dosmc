#include <dosmc.h>

int main(int argc, char **argv) {
  for (; argc > 0; --argc) {
    putchar('+');
  }
  putchar('\r'); putchar('\n');
  while (*argv) {
    putchar('(');
    oputs(*argv++);
    putchar(')'); putchar('\r'); putchar('\n');
  }
  return 0;
}
