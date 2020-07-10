;
; helloc2.nasm: feature dosmc and NASM DOS .com compatibility demo
; by pts@fazekas.hu at Fri Jul 10 03:25:34 CEST 2020
;
; DOS .com source file in NASM syntax, identical with `nasm -f bin' and dosmc:
;
;   $ ./dosmc -mt examples/helloc2.nasm  # Creates examples/helloc2.com .
;   $ nasm -f bin -O9 -o examples/helloc2b.com examples/helloc2.nasm
;   $ cmp examples/helloc2.com examples/helloc2b.com  # Identical.
;
; It can also be compiled to DOS .exe:
;
;   $ ./dosmc examples/helloc2.nasm  # Creates examples/helloc2.exe .
;
; Use the PSP to fetch command-line arguments (they start at PSP+0x80).
; For .com files, the PSP is at cs:0 == ds:0 == es:0 == ss:0.
; For .exe files in DOS .com compatibility mode, the PSP is at es:0.
; You can also get the PSP segment to es any time with:
; mov ah, 0x62;; int 0x21;; mov es, bx.
;

org 0x100  ; Also enables DOS .com compatibility mode for dosmc.

mov ah, 9  ; WRITE_TO_STDOUT.
mov dx, msg
int 0x21
mov cx, skip2  ; Just to demonstrate address calculation within .bss.
ret

; A `segment const align=1' or `segment data align=1' line is needed for
; dosmc .exe output only, to put msg to the segment pointed by ds.
segment const align=1

msg: db 'Hello, World!', 13, 10, '$'

; The name of the BSS segment must be .bss (starting with a dot, lower case)
; for `nasm -f bin'.
;
; Values in .bss are unintialized in DOS .com files, and DOS .com
; compatibility mode also keeps this.
segment .bss align=1

skip1: resb 0x2000
skip2: resb 4

segment data align=1
db 'InData', 0

; Add something more to segment const. Will be put earlier than segment data
; (e.g. InData) within the output .com or .exe file.
segment const
db 'InConst', 0
