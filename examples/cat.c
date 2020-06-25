#include <stdio.h>

int main(int argc, char **argv) {
  int i;
  (void)argc; (void)argv;
  while ((i = getchar()) >= 0) {
    /* if (i >= 32) putchar(':'); */
    putchar(i);
  }
  return 0;
}
