__LINKER_FLAG(omit_cld)
__LINKER_FLAG(uninitialized_bss)
__LINKER_FLAG(start_es_psp)

..start:  ; Either ..start: or _start_ or both works.
_start_:
mov ah, 9  ; WRITE_TO_STDOUT.
mov dx, msg
int 0x21
ret

segment const
msg: db 'Hello, World!', 13, 10, '$'

segment .bss
resb 42
