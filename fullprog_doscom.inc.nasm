;
; fullprog_doscom.inc.nasm: NASM include library for building tiny DOS .com prog
; by pts@fazekas.hu at Wed Jun 24 19:00:40 CEST 2020
;
; This library generates a DOS .com file (without signature), and it uses the
; tiny memory model: cs==ds==ss, limits are:
; sizeof(code+data+bss+stack) <= 65276 bytes. This library is compatible with
; old (e.g. 0.98.39 on 2005-01-15) and new (e.g. 2.14.02 on 2018-12-26)
; versions of NASM.
;
; Example mycom.nasm source usage:
;
;   %include "fullprog_doscom.inc.nasm"
;   fullprog_code
;   ...  ; 8086 (16-bit) assembly code here. Starts at top. No need to ret.
;   fullprog_data
;   ...  ; Data like `mylabel: dw 42' here.
;   fullprog_bss
;   ...  ; Uninitialized data like: `myvar: resw 1' here.
;   fullprog_end [stack_size]
;
; Compilation (assembling): nasm -f bin -o mycom.com mycom.nasm
;
; Disassembling: ndisasm -b 16 -o 0x100 mycom.com
;
; At startup, ds:... and ss:... are the data, cs:ip is the code (ip is typically
; 0x100 after fullprog_code), ss:sp is the top of stack (grows downwards).
; At startup, cs:0, ds:0, es:0, ss:0 are the PSP, command-line arguments are
; at es:0x80.
; At startup, flags (e.g. d) and registers ax, bx, cx, dx, si, di and bp are
; not initialized.
; At exit, can leave stuff on the stack.
;
; Before startup, bss is not zero-initialized by DOS (!)
; (https://stackoverflow.com/q/62561553/97248).
;

%macro fullprog___check_empty 0
times $$-$ db 0  ; Fails if there is any code or data in front of `fullprog_code'.
%endmacro

%macro fullprog_code 0
%ifdef fullprog_code_called
%fatal please do not call fullprog_code twice or too late
%endif
%define fullprog_code_called
fullprog___check_empty
bits 16
section .text align=1 vstart=0x100  ; org 0x100
code_start:
start:
%endmacro

%macro fullprog_data 0
%ifdef fullprog_data_called
%fatal please do not call fullprog_data twice or too late
%endif
%ifndef fullprog_code_called
fullprog_code
%endif
%define fullprog_data_called
%ifndef fullprog_omit_code_exit  ; Use `%define fullprog_omit_code_exit' to omit this.
code_exit:
ret  ; Same as EXIT(0) for .com file if sp is restored.
;mov ax, 0x4c00  ; EXIT, exit code in al; `ret' in .com files doesn't work in .exe files.
;int 0x21
%endif
code_end:
; Fails with `error: TIMES value -... is negative' if code is too large (>~64 KiB).
times -((code_end-code_start+0x100)>>16) db 0
section .data align=1 vstart=0x100+(code_end-code_start)  ; vfollows=.text is off by 2 bytes.
data_start:
%endmacro

%macro fullprog_bss 0
%ifdef fullprog_bss_called
%fatal please do not call fullprog_end twice or too late
%endif
%ifndef fullprog_data_called
fullprog_data
%endif
%define fullprog_bss_called
data_end:
section .bss align=1 ; vstart=0
bss_start:
%endmacro

%macro fullprog___check_end 0
%ifdef fullprog_end_called
%fatal please do not call fullprog_end twice or too late
%endif
%ifndef fullprog_bss_called
fullprog_bss
%endif
%endmacro

; %1 is stack size in bytes.
%macro fullprog_end 1
fullprog___check_end
%define fullprog_end_called
times (%1-10)>>256 resb 0  ; Assert that stack size is at least 10.
; This is fake, end of stack depends on DOS, typically sp==0xfffe or sp==0xfffc.
stack: resb %1
bss_end:
call__fullprog_end:  ; Make fullprog_code without fullprog_end fail.
; Fails with `error: TIMES value -... is negative' if data is too large (>~64 KiB).
; +3 because some DOS systems set sp to 0xfffc instead of 0xffff
; (http://www.fysnet.net/yourhelp.htm).
times -(((bss_end-bss_start)+(data_end-data_start)+(code_end-code_start+0x100)+3)>>16) db 0
%endmacro

; Autodetects stack size to fill data segment to almost 65535 bytes.
%macro fullprog_end 0
fullprog___check_end
auto_stack:
fullprog_end 65535-3-((auto_stack-bss_start)+(data_end-data_start)+(code_end-code_start+0x100))
%endmacro
