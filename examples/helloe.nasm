;
; helloe.nasm: simple dosmc and NASM+WLINK DOS .exe compatibility demo
; by pts@fazekas.hu at Tue Jul 14 22:53:21 CEST 2020
;
; The difference between hellod.nasm and helloe.nasm is that hellod.nasm
; defines and uses `group dgroup'.
;
; It can be compiled to DOS .exe using NASM+WLINK:
;
;   $ nasm -f obj -O9 -o examples/helloew.obj examples/helloe.nasm
;   $ wlink option quiet format dos file examples/helloew.obj  # Creates examples/helloew.exe
;
; It cannot be compiled to DOS .com using NASM+WLINK, because `mov ax, data'
; in the boilerplate below doesn't work in .com.
;
; It can be compiled to DOS .exe using dosmc:
;
;   $ ./dosmc examples/helloe.nasm  # Creates examples/helloe.exe
;   $ cmp examples/helloew.exe examples/helloe.exe
;   (It doesn't match, but the functionality is identical.)
;
; It can be compiled to DOS .com using dosmc:
;
;   $ ./dosmc -mt examples/helloe.nasm  # Creates examples/helloe.com
;
; Please note that the boilerplate below can be removed for dosmc, but it's
; needed by NASM+WLINK.
;

bits 16  ; Optional.

segment code

..start:
mov ax, data      ; Will be replaced with nop()s.
mov ds, ax
mov ax, stack     ; Will be replaced with nop()s.
mov ss, ax
mov sp, stacktop  ; Will be replaced with the final maximum stacktop.

mov dx, hello
mov ah, 9
int 0x21

mov ax, 0x4c00
int 0x21

segment data

hello: db 'Hello, World!', 13, 10, '$'

segment stack stack
resb 64
stacktop:
