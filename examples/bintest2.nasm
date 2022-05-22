; Produces the same .bin file as bintest3.asm.
org 0x500
%define ANSWER 42
dw answer2
answer2: dw ANSWER+2
dw answer2d
dw answer2
inc bx
db answer3d - _DATA  ; OMF .obj doesn't support 1-byte relocation.
times 98765 nop
my_cli:
cli
dd my_cli + 0x8000
_DATA:
answer2d: dw 0xb
answer3d: dw 0x13
dw answer2
dd my_cli
