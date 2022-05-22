org 0x500
%define ANSWER 42
dw answer2
answer2: dw ANSWER+2
dw answer2d
dw answer2
inc bx
answer2d: dw 0xb
dw answer2
