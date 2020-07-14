;
; hellod.nasm: simple dosmc and NASM+WLINK DOS .exe dgroup compatibility demo
; by pts@fazekas.hu at Tue Jul 14 22:53:21 CEST 2020
;
; The difference between hellod.nasm and helloe.nasm is that hellod.nasm
; defines and uses `group dgroup'.
;
; It can be compiled to DOS .exe using NASM+WLINK:
;
;   $ nasm -f obj -O9 -o examples/hellodw.obj examples/hellod.nasm
;   $ wlink option quiet format dos file examples/hellodw.obj  # Creates examples/hellodw.exe
;
; It cannot be compiled to DOS .com using NASM+WLINK, because `mov ax, dgroup'
; in the boilerplate below doesn't work in .com.
;
; It can be compiled to DOS .exe using dosmc:
;
;   $ ./dosmc examples/hellod.nasm  # Creates examples/hellod.exe
;   $ cmp examples/hellodw.exe examples/hellod.exe
;   (It doesn't match, but the functionality is identical.)
;
; It can be compiled to DOS .com using dosmc:
;
;   $ ./dosmc -mt examples/hellod.nasm  # Creates examples/hellod.com
;
; Please note that the boilerplate below can be removed for dosmc, but it's
; needed by NASM+WLINK.
;

bits 16  ; Optional.

segment code
..start:

group dgroup data stack

; Boilerplate.
mov ax, dgroup    ; Will be replaced with nop()s.
mov ds, ax
mov ax, dgroup    ; Will be replaced with nop()s.
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
resb 32  ; Unused but fun to have.
