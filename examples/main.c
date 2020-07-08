/* * Compile with: ./dosmc -nq -mt examples/main.c examples/lib.c
 * * Check that lib2.c is not included (because it doesn't define a useful symbol):
 *   ./dosmc -nq -mt examples/main.c examples/lib2.c examples/lib.c
 */
#include <dosmc.h>

extern int answer(int);

extern int delta2;
int delta = 5;

int main(void) {
  _printmsgx("Hello, $");
  return answer(delta2);
}
