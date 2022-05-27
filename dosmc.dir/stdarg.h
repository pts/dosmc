#ifndef _STDARG_H_
#define _STDARG_H_ 1
#pragma once

typedef char *va_list;

/* void va_start(va_list ap, last); */
#define va_start(ap, last) ((ap)=(char *)&(last)+ ((sizeof(last)+sizeof(int)-1)&~(sizeof(int)-1)),(void)0)

/* type va_arg(va_list ap, type); */
#define va_arg(ap, type) ((ap)+= ((sizeof(type)+sizeof(int)-1)&~(sizeof(int)-1)), (*(type *)((ap)-((sizeof(type)+sizeof(int)-1)&~(sizeof(int)-1)))))

/* void va_end(va_list ap); */
#define va_end(ap) ((ap)=0,(void)0)

/* void va_copy(va_list dest, va_list src); */
#define va_copy(dest, src) ((dest)=(src),(void)0)

#endif  /* _STDARG_H_ */
