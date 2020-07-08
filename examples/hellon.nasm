; Can be used instead of `..start:':
;global _start_
;_start_:

..start:
mov ah, 9
mov dx, msg
int 0x21
ret

segment const
msg: db 'Hello, World!', 13, 10, '$'
