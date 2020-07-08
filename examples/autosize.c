#include <dosmc.h>

void _start(void) {
  _printmsgx_autosize("Hello");
  _printmsgx_autosize((const char far*)"Hello");
}
