#ifndef _DOSMC_H_
#define _DOSMC_H_ 1

static inline int _printmsgx(const char *msg);
#pragma aux _printmsgx = \
"mov ah, 9" /* WRITE_STDOUT */ \
"int 0x21" \
parm [ dx ] \
modify [ ah ];

/* TODO(pts): Make it not inline. */
/* Binary safe when redirected. */
static void putchar(char c);
#pragma aux putchar = \
"mov ah, 2" \
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

/* TODO(pts): Make it not inline. */
/* Binary safe when redirected. */
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

#if 0
"mov ah, 0" \
"jnc next" \
"sbb ax, ax" /* ax := -1 */ \
"next:" \
"stc" \
"sbb ax, ax" \

#endif

#endif  /* _DOSMC_H_ */
