; Can be used instead of `..start:':
;global _start_
;_start_:

__LINKER_FLAG(omit_cld)
__LINKER_FLAG(uninitialized_bss)

..start:
mov ah, 9
mov dx, msg
int 0x21
ret

segment const
msg: db 'Hello, World!', 13, 10, '$'

segment .bss
resb 42
