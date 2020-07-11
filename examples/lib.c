#include <dosmc.h>

extern int delta;
int delta2 = 2;
extern char *get_msg(void);

int answer(int delta2c) {
  _printmsgx(delta + get_msg() /* "12345Wo$" */);
  _printmsgx(delta2c + "12rld!\r\n$");
  return 42;
}

