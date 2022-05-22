; Produces the same .bin file as bintest2.nasm and bintest3.asm.
.model flat  ; Must be the first directive for dosmc to detect it. Also implies use32 (32-bit assembly instrutions) and 386 processor.
.data
answer2d: dw 0xb
answer3d: dw 0x13
dw answer2
dd offset my_cli  ; `offset' is still a 2-byte relocation, but since it points to _TEXT, the dosmc linker skips it, and all 4 bytes are correct.
.code
org 500h
ANSWER equ 42
dw answer2
answer2: dw ANSWER+2
dw answer2d
dw answer2
inc ebx
db offset answer3d - _TEXT  ; wasm is buggy: we get the same result with _TEXT instead of _DATA here.
db (98765) dup (90h)
my_cli:
cli
dd offset my_cli + 8000h  ; `offset' is still a 2-byte relocation, but since it points to _TEXT, the dosmc linker skips it, and all 4 bytes are correct.
db 66h
mov eax, 5678abcdh
db 66h
mov eax, offset answer3d
;dd (offset answer2) + 0ffffh  ; SUXX: This is still 2-byte relocation.
;dd (offset answer2) + 0h  ; SUXX: This (offset) is still 2-byte relocation. There is no offset386.
;dw (offset answer2) shr 16  ; E074: Constant operand is expected
end
