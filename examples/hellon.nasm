global _start_
_start_:

mov ah, 9
mov dx, msg
int 0x21
ret

segment const
msg: db 'Hello, World!', 13, 10, '$'
