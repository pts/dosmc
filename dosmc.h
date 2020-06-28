#ifndef _DOSMC_H_
#define _DOSMC_H_ 1

static inline int _printmsgx(const char *msg);
#pragma aux _printmsgx = \
"mov ah, 9" /* WRITE_STDOUT */ \
"int 0x21" \
parm [ dx ] \
modify [ ah ];

/* Writes single byte to stdout. Binary safe when redirected. */
/* TODO(pts): Make it not inline. */
static void putchar(char c);
#pragma aux putchar = \
"mov ah, 2"  /* 0x40 would also work, see eputc */ \
"int 0x21" \
parm [ dl ] \
modify [ ax ];
#if 0  /* Correct but longer. */
#pragma aux putchar = \
"push ax" \
"mov ah, 0x40" \
"mov bx, 1"  /* stdout */ \
"mov cx, bx"  /* 1 byte */ \
"mov dx, sp" \
"int 0x21" \
"pop ax" \
parm [ al ] \
modify [ bx cx dx ];  /* Also modifies cf */
#endif

/* Writes single byte to stderr. Binary safe when redirected. */
/* TODO(pts): Make it not inline. */
static void eputc(char c);
#pragma aux eputc = \
"push ax" \
"mov ah, 0x40" \
"mov bx, 2"  /* stderr */ \
"mov cx, 1"  /* 1 byte */ \
"mov dx, sp" \
"int 0x21" \
"pop ax" \
parm [ al ] \
modify [ bx cx dx ];  /* Also modifies cf */

/* Reads single byte (0..255) from stdin, returns -1 on EOF or error. */
/* TODO(pts): Make it not inline. */
static int getchar(void);
#pragma aux getchar = \
"mov ah, 0x3f" \
"xor bx, bx"  /* stdin */ \
"mov cx, 1"  /* 1 byte */ \
"push cx" \
"mov dx, sp" \
"int 0x21" \
"pop bx" \
"jc err" \
"dec ax" \
"jnz done" \
"xchg ax, bx"  /* al := data byte; ah := 0 */ \
"jmp short done" \
"err:\n" \
"sbb ax, ax"  /* ax := -1 */ \
"done:" \
value [ ax ] \
modify [ bx cx dx ]

static inline void exit(int status);
#pragma aux exit = \
"mov ah, 0x4c" \
"int 0x21" \
aborts \
parm [ al ] \
modify [ ah ];

#endif  /* _DOSMC_H_ */
