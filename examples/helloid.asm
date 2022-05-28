ideal  ; Optional for LZASM. Makes this file work with TASM as well. Also dosmc will autodetect it.
model small

dataseg  ; Set segment alignment to byte (now it's word).
lpText:	db "Hello, World!", 13, 10, '$'

codeseg
	startupcode  ; Works in TASM 2.0, doesn't work in TASM 1.01.
	lea dx,[lpText]  ; TASM 3.0 converts this to a mov, WASM doesn't.
	mov dx,offset lpText
	mov ah,9
	int 21h
	exitcode 0  ; Works in TASM 3.0, it doesn't work in TASM 2.51.
end  ; Also optional for LZASM. TASM 5.0 needs it.
