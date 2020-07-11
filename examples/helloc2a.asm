;
; helloc2a.asm: feature MASM+WASM demo
; by pts@fazekas.hu at Fri Jul 10 20:36:15 CEST 2020
;
; DOS source file in MASM+WASM syntax, should produce identical .com and .exe
; files to examples/helloc2.nasm. For .com output:
;
;   $ ./dosmc -mt examples/helloc2.nasm  # Creates examples/helloc2.com .
;   $ ./dosmc -mt examples/helloc2a.asm  # Creates examples/helloc2w.com .
;   $ nasm -f bin -O9 -o examples/helloc2b.com examples/helloc2.nasm
;   $ cmp examples/helloc2.com examples/helloc2b.com  # Identical.
;   $ cmp examples/helloc2.com examples/helloc2a.com  # Identical.
;
; For .exe output:
;
;   $ ./dosmc examples/helloc2.nasm  # Creates examples/helloc2.exe .
;   $ ./dosmc examples/helloc2a.asm  # Creates examples/helloc2w.exe .
;   $ cmp examples/helloc2.exe examples/helloc2a.exe  # Identical.
;
; This file is similar to examples/helloc2w.wasm, but in addition to WASM,
; it's compatible (and produces identical output) with older DOS assemblers:
;
; * Microsoft MASM 3.00 (1984): asm helloc2a helloc2a nul nul
; * Microsoft MASM 4.00 (1985): asm helloc2a helloc2a nul nul
; * A86 3.22 (1990): a86 helloc2a.asm helloc2a.obj
; * A86 4.05 (2000): a86 helloc2a.asm helloc2a.obj
;
; See examples/helloc2l.asm for equivalent assembly code compatible with LZASM.
;
; The line breaks were changed to CRLF (\r\n), because LF (\n) didn't work
; for MASM 3.00 (bit it worked for MASM 4.0).
;
; Use the PSP to fetch command-line arguments (they start at PSP+0x80).
; For .com files, the PSP is at cs:0 == ds:0 == es:0 == ss:0.
; For .exe files in DOS .com compatibility mode, the PSP is at es:0.
; You can also get the PSP segment to es any time with:
; mov ah, 0x62;; int 0x21;; mov es, bx.
;

;PUBLIC _start_  ; Optional.
EXTRN __linker_flag_start_es_psp:BYTE
EXTRN __linker_flag_uninitialized_bss:BYTE
EXTRN __linker_flag_omit_cld:BYTE

DGROUP GROUP CONST,CONST2,_DATA,_BSS  ; Required by MASM 3.0 and 4.0.

; MASM 3.0 and 4.0 don't understand USE16 after PUBLIC, so omitted.
_BSS SEGMENT BYTE PUBLIC 'BSS'
  skip1 LABEL BYTE
  ORG 2000H
  skip2 LABEL BYTE
  ORG 2004H
_BSS ENDS

CONST SEGMENT BYTE PUBLIC 'DATA'
  msg db 'Hello, World!', 13, 10, '$'
CONST ENDS

_DATA SEGMENT BYTE PUBLIC 'DATA'
  db 'InData', 0
_DATA ENDS

CONST SEGMENT BYTE PUBLIC 'DATA'
  db 'InConst', 0
CONST ENDS

CONST2 SEGMENT BYTE PUBLIC 'DATA'  ; Required because DGROUP.
CONST2 ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE'
  ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
  ;_start_:  ; Optional if entry is present.
  entry:  ; `END entry' below specifies the entry point.
  mov ah, 9
  mov dx, offset msg
  int 21H
  mov cx, offset skip2
  ret
_TEXT ENDS

END entry
