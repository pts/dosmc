/* To get a minimal hello.com executable (26 bytes), compile with:
 * ./dosmc -mt examples/hello.c
 */

#include <dosmc.h>

static const STRING_WITHOUT_NUL(msg, "Hello, World!\r\n$");

void _start(void) {
  _printmsgx(msg);
}
