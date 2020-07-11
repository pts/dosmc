/* * Compile with: ./dosmc -nq examples/main.c examples/lib.c examples/lib3.c
 * * Check that lib2.c is excluded (because it doesn't define a useful symbol):
 *   ./dosmc -nq examples/main.c examples/lib.c examples/lib2.c examples/lib3.c
 * * Compile a static library:
 *   ./dosmc -nq -cl -fo=examples/mlib.lib examples/lib.c examples/lib2.c examples/lib3.c
 * * Compile an executable which calls function in the static library (lib2.c is excluded):
 *   ./dosmc -nq examples/main.c examples/mlib.lib
 */
#include <dosmc.h>

extern int answer(int);

extern int delta2;
int delta = 5;
extern int unused_extern;

int main(void) {
  _printmsgx("Hello, $");
  return answer(delta2);
}
