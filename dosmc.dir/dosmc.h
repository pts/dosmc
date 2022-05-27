#ifndef _DOSMC_H_
#define _DOSMC_H_ 1
#pragma once

#ifdef __cplusplus
#define NULL 0
#else
#define NULL ((void *)0)  /* stdlib.h */
#endif

#define __PRAGMA(X) _Pragma(#X)

#define _WCNORETURN __declspec(aborts)

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef char int8_t;
typedef short int16_t;
typedef long int32_t;
typedef unsigned int size_t;  /* TODO(pts): 64-bit tcc. */
typedef int ssize_t;  /* TODO(pts): 64-bit tcc. */

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
 *   functions can modify es any time without restoring it. !! Really, where is this (es) documented?
 * Example: __LINKER_FLAG(force_argc_zero)
 *   Force argc=0 and argv=NULL for main, no matter what was speficied in
 *   the command line. This makes the executable shorter. Alternatively, you
 *   can specify int main(void) { ... } and get even more savings.
 * Example: __LINKER_FLAG(uninitialized_argc)
 *   Don't initialize argc and argv in main. This makes the executable
 *   shorter. Alternatively, you can specify int main(void) { ... } and get
 *   even more savings.
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

/* Writes a '$'-terminated string (with far pointer) to stdout. */
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
 * ... printmsgx(msg);
 */
#define STRING_WITHOUT_NUL(name, value) char name[sizeof(value) - 1] = value

/* Writes a '\0'-terminated string to the file descriptor. */
/* TODO(pts): Make it not inline. */
static void fdputs(int fd, const char *s);
#pragma aux fdputs = \
"push ds" \
"pop es" \
"mov cx, -1" \
"mov ax, 0x4000" /* WRITE in ah, 0 in al for scasb */ \
"mov dx, di"  /* dx will point to the buffer (s argument) */ \
"repnz scasb" \
"not cx" \
"dec cx"  /* cx will be the number of bytes to write */ \
"int 0x21" \
parm [ bx ] [ di ] \
modify [ ax cx dx di ];  /* Also modifies cf */

/* TODO(pts): Make it not inline, in case it's called multiple times. */
/* This implementation is optimized for size. */
size_t strlen(const char *s);
static size_t strlen_inline(const char *s);
#pragma aux strlen_inline = \
"mov ax, -1" \
"again: cmp byte ptr [si], 1" \
"inc si" \
"inc ax" \
"jnc again" \
parm [ si ] \
modify [ si ];

int memcmp(const void *s1, const void *s2, size_t n);
static int memcmp_inline(const void *s1, const void *s2, size_t n);
#pragma aux memcmp_inline = \
"xor ax, ax" \
"repz cmpsb" \
"je @$done" \
"inc ax" \
"jnc @$done" \
"neg ax" \
"@$done:" \
parm [ si ] [ di ] [ cx] \
modify [ si di cx ];

int strcmp(const char *s1, const char *s2);
static int strcmp_inline(const char *s1, const char *s2);
#pragma aux strcmp_inline = \
"xor ax, ax" \
"mov cx, -1" \
"repz cmpsb" \
"je @$done" \
"inc ax" \
"jnc @$done" \
"neg ax" \
"@$done:" \
parm [ si ] [ di ] \
modify [ si di cx ];

char *strcpy(char *dest, const char *src);
static char *strcpy_inline(char *dest, const char *src);
#pragma aux strcpy_inline = \
"push di" \
"@$again: lodsb" \
"stosb" \
"cmp al, 0" \
"jne @$again" \
"pop ax" \
parm [ di ] [ si ] \
modify [ si di ];

char *strcat(char *dest, const char *src);

int tolower(int c);
int toupper(int c);
int isdigit(int c);
int isxdigit(int c);
int isalpha(int c);
int isspace(int c);

/* Writes a '\0'-terminated string to stdout. */
static inline void oputs(const char *s) {
  fdputs(1, s);
}

/* Writes a '\0'-terminated string to stderr. */
static inline void eputs(const char *s) {
  fdputs(2, s);
}

/* Writes single byte to stdout. Binary safe when redirected. */
static void putchar(char c);
#pragma aux putchar = \
"mov ah, 2"  /* 0x40 would also work, see eputc */ \
"int 0x21" \
parm [ dl ] \
modify [ ax ];
#if 0  /* Correct but longer. */
#pragma aux putchar = \
"push ax"  /* byte to print at sp */ \
"mov ah, 0x40" \
"mov bx, 1"  /* stdout */ \
"mov cx, bx"  /* 1 byte */ \
"mov dx, sp" \
"int 0x21" \
"pop ax" \
parm [ al ] \
modify [ bx cx dx ];  /* Also modifies cf */
#endif

/* Writes CRLF ("\r\n") to stdout. */
static void oputcrlf(void);
#pragma aux oputcrlf = \
"mov ah, 2" \
"mov dl, 13" \
"int 0x21" \
"mov dl, 10" \
"int 0x21" \
parm [ dl ] \
modify [ ax ];

/* Writes a '\0'-terminated string + CRLF ("\r\n") to stdout.
 * The C standard requires "\n" instead of CRLF.
 * TODO(pts): Make it not inline.
 */
static inline void puts(const char *msg) {
  oputs(msg);
  oputcrlf();
}

/* Writes single byte to stderr. Binary safe when redirected. */
/* TODO(pts): Make it not inline. */
static void eputc(char c);
#pragma aux eputc = \
"push ax"  /* byte to print at sp */ \
"mov ah, 0x40" /* WRITE */ \
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
parm [ ax ] \
modify [ ah ];

int remove(const char *pathname);
int unlink(const char *pathname);  /* Same as remove(). */

ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);

#endif  /* _DOSMC_H_ */
