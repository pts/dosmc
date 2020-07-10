#ifndef _DOSMC_H_
#define _DOSMC_H_ 1

#ifdef __cplusplus
#define NULL 0
#else
#define NULL ((void *)0)  /* stdlib.h */
#endif

#define __PRAGMA(X) _Pragma(#X)

/* Can be specified multiple times (and will be emitted once each for .c,
 * and deduplicate for .nasm). Works with or without trailing semicolon.
 * Works in both .c and .nasm source files.
 *
 * Example: __LINKER_FLAG(omit_cld)
 *   to omit the cld instruction before calling the entry point.
 * Example: __LINKER_FLAG(uninitialized_bss)
 *   to keep _BSS uninitialized (rather than filling it with \x00.
 * Example: __LINKER_FLAG(start_es_psp)
 *   to make es:0 point to the PSP (Program Segment Prefix) at the entry
 *   point. Not enabled by default, because in the Watcom calling convention
 *   functions can modify es any time without restoring it.
 */
#define __LINKER_FLAG(name) extern int _linker_flag_##name; __PRAGMA(extref _linker_flag_##name)


/* Writes a $-delimited string to stdout. You may want to create msg with
 * STRING_WITHOUT_NUL to save 1 byte.
 *
 * When writing to the console, \r\n is needed for a line break. In DOSBox,
 * \n also works, but in FreeDOS 1.2, \n only moves down, not to the
 * beginning to the next line.
 */
static inline void _printmsgx(const char *msg);
#pragma aux _printmsgx = \
"mov ah, 9" /* WRITE_STDOUT */ \
"int 0x21" \
parm [ dx ] \
modify [ ah ];

/* Writes a $-delimited string (with far pointer) to stdout. */
static inline void _printmsgx_far(const char far *msg);
#pragma aux _printmsgx_far = \
"mov ah, 9" /* WRITE_STDOUT */ \
"push ds" \
"push es" \
"pop ds" \
"int 0x21" \
"pop ds" \
parm [ es dx ] \
modify [ ah ];

#define _printmsgx_autosize(msg) ((sizeof((msg)+0) == sizeof(const char*)) ? _printmsgx((const char*)(int)msg) : _printmsgx_far(msg))

/* Example usage:
 * static const STRING_WITHOUT_NUL(msg, "Hello, World!\r\n$");
 */
#define STRING_WITHOUT_NUL(name, value) char name[sizeof(value) - 1] = value

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
