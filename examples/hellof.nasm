;
; hellof.nasm: simple dosmc and NASM+WLINK DOS .exe as-is compatibility demo
; by pts@fazekas.hu at Tue Jul 14 22:53:21 CEST 2020
;
; hellof.nasm is similar to helloe.nasm, but its actual code is unmodified,
; as-is example code copy-pasted from the web.
;
; It can be compiled to DOS .exe using NASM+WLINK:
;
;   $ nasm -f obj -O9 -o examples/hellofw.obj examples/hellof.nasm
;   $ wlink option quiet format dos file examples/hellofw.obj  # Creates examples/hellofw.exe
;
; It cannot be compiled to DOS .com using NASM+WLINK, because `mov ax,data'
; in the boilerplate below doesn't work in .com.
;
; It can be compiled to DOS .exe using dosmc:
;
;   $ ./dosmc examples/hellof.nasm  # Creates examples/hellof.exe
;   $ cmp examples/hellofw.exe examples/hellof.exe
;   (It doesn't match, but the functionality is identical.)
;
; It can be compiled to DOS .com using dosmc:
;
;   $ ./dosmc -mt examples/hellof.nasm  # Creates examples/hellof.com
;
; Please note that boilerplate (between `mov ax,data' and `mov sp,stacktop',
; inclusive) can be removed for dosmc, but it's needed by NASM+WLINK.
;
; The rest of the file is unmodified, as-is example code copy-pasted from
; https://bigcode.wordpress.com/2018/05/20/nasm-16-bit-exe-file-example/

BITS 16

segment code

..start:
mov ax,data
mov ds,ax
mov ax,stack
mov ss,ax
mov sp,stacktop

mov dx,hello
mov ah,9
int 0x21

mov ax,0x4c00
int 0x21

segment data

hello: db 'Hello World', 13, 10, '$'

segment stack stack
resb 64
stacktop:
