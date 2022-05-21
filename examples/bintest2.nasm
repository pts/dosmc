%define ANSWER 42
dw answer2
answer2: dw ANSWER+2
dw answer2
inc bx
