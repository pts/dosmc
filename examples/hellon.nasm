__LINKER_FLAG(omit_cld)
__LINKER_FLAG(uninitialized_bss)

;..start:  ; Either ..start: or _start_ works.
_start_:
mov ah, 9
mov dx, msg
int 0x21
ret

segment const
msg: db 'Hello, World!', 13, 10, '$'

segment .bss
resb 42
