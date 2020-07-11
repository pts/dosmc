;
; helloc2l.asm: feature LZASM demo (doesn't compile with WASM or NASM)
; by pts@fazekas.hu at Sat Jul 11 10:36:20 CEST 2020
;
; DOS source file in LZASM syntax, should produce identical .com and .exe
; files to examples/helloc2.nasm. For .com output:
;
;   $ ./dosmc -mt examples/helloc2.nasm  # Creates examples/helloc2.com .
;   $ dosbox examples  # C:\>lzasmx helloc2l.asm  # Creates examples/HELLOC2L.obj .
;   $ mv examples/HELLOC2L.OBJ examples/helloc2l.obj  # After DOSBox.
;   $ ./dosmc -mt examples/helloc2l.obj
;   $ cmp examples/helloc2.com examples/helloc2l.com  # Identical.
;
; For .exe output:
;
;   $ ./dosmc examples/helloc2.nasm  # Creates examples/helloc2.exe .
;   $ ./dosmc examples/helloc2l.obj  # Creates examples/helloc2l.exe .
;   $ cmp examples/helloc2.exe examples/helloc2l.exe  # Identical.
;
; This file is similar to examples/helloc2w.wasm, but the syntax has been
; changed to make it compatible with LZASM 0.56 (lzasmx.exe).
;
; Use the PSP to fetch command-line arguments (they start at PSP+0x80).
; For .com files, the PSP is at cs:0 == ds:0 == es:0 == ss:0.
; For .exe files in DOS .com compatibility mode, the PSP is at es:0.
; You can also get the PSP segment to es any time with:
; mov ah, 0x62;; int 0x21;; mov es, bx.
;

; Optional in LZASM. If specified, DGROUP below becomes optional, and makes
; `BYTE' in `SEGMENT _DATA' and `SEGMENT _TEXT' an error (Segment attributes
; illegally redefined).
;MODEL small  ; Required by LZASM.

;PUBLIC _start_  ; Optional.
EXTRN __linker_flag_start_es_psp:BYTE
EXTRN __linker_flag_uninitialized_bss:BYTE
EXTRN __linker_flag_omit_cld:BYTE

GROUP DGROUP CONST,CONST2,_DATA,_BSS  ; Makes CONST2 required.

SEGMENT _BSS BYTE PUBLIC 'BSS'
  LABEL skip1 BYTE
  ORG 2000H
  LABEL skip2 BYTE
  ORG 2004H
ENDS _BSS

SEGMENT CONST BYTE PUBLIC 'DATA'
  msg db 'Hello, World!', 13, 10, '$'
ENDS CONST

SEGMENT _DATA BYTE PUBLIC 'DATA'
  db 'InData', 0
ENDS _DATA

SEGMENT CONST BYTE PUBLIC 'DATA'
  db 'InConst', 0
ENDS CONST

SEGMENT CONST2 BYTE PUBLIC 'DATA'  ; Required only if DGROUP is defined.
ENDS CONST2

SEGMENT _TEXT BYTE PUBLIC 'CODE'
  ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
  ;_start_:  ; Optional if entry is present.
  entry:  ; `END entry' below specifies the entry point.
  mov ah, 9
  mov dx, offset msg
  int 21H
  mov cx, offset skip2
  ret
ENDS _TEXT

END entry
