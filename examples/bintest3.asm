; Produces the same .bin file as bintest2.nasm.
.data
answer2d: dw 0xb
dw answer2
.code
org 500h
ANSWER equ 42
dw answer2
answer2: dw ANSWER+2
dw answer2d
dw answer2
inc bx
;db (98765) dup (90h)
end
