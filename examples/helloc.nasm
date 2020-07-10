;
; helloc.nasm: simple dosmc and NASM DOS .com compatibility demo
; by pts@fazekas.hu at Fri Jul 10 03:25:34 CEST 2020
;
; DOS .com source file in NASM syntax, identical with `nasm -f bin' and dosmc:
;
;   $ ./dosmc -mt examples/helloc.nasm  # Creates examples2/helloc.com .
;   $ nasm -f bin -O9 -o examples/hellocb.com examples/helloc.nasm
;   $ cmp examples/helloc.com examples/hellocb.com  # Identical.
;
; It can also be compiled to DOS .exe:
;
;   $ ./dosmc examples/helloc.nasm  # Creates examples/helloc.exe .
;

org 0x100  ; Also enables DOS .com compatibility mode for dosmc.

mov ah, 9  ; WRITE_TO_STDOUT.
mov dx, msg
int 0x21
ret

; A `segment const align=1' or `segment data align=1' line is needed for
; dosmc .exe output only, to put msg to the segment pointed by ds.
segment const align=1

msg: db 'Hello, World!', 13, 10, '$'
