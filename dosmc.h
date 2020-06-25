#ifndef _DOSMC_H_
#define _DOSMC_H_ 1

static int _printmsgx(const char *msg);
#pragma aux _printmsgx = \
"mov ah, 9" /* WRITE_STDOUT */ \
"int 0x21" \
parm  [ dx ] \
modify [ ax ];

/* Only with static, both get_str and the string literal will be optimized away. */
static char *example_get_str(void) {
  return "LONG STRING";
}

#endif  /* _DOSMC_H_ */

