/*
 * Compiling this example with Docker
 *
 * Build and run the docker-compose.yaml file in the directory above this:
 *
 * cd ..
 * docker-compose up
 *
 * The Docker container will remain running. In a new shell:
 *
 * docker exec -it -w /home/dosmc dosmc ./dosmc -mt /code/hello.c
 *
 */

#include <dosmc.h>

static const STRING_WITHOUT_NUL(msg, "Hello, World!\r\n$");

void _start(void) {
  _printmsgx(msg);
}
