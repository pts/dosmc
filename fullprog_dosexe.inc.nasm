;
; fullprog_dosexe.inc.nasm: NASM include library for building tiny DOS .exe prog
; by pts@fazekas.hu at Wed Jun 24 19:00:40 CEST 2020
;
; This library generates a DOS .exe file (with MZ signature), and it uses the
; small memory model: cs!=ds==ss, limits are: sizeof(code) <= 65528 bytes,
; sizeof(data+bss+stack) <= 65520 bytes. This library is compatible with
; old (e.g. 0.98.39 on 2005-01-15) and new (e.g. 2.14.02 on 2018-12-26)
; versions of NASM.
;
; Example myexe.nasm source usage:
;
;   %include "fullprog_dosexe.inc.nasm"
;   fullprog_code
;   ...  ; 8086 (16-bit) assembly code here. Starts at top. No need to ret.
;   fullprog_data
;   ...  ; Data like `mylabel: dw 42' here.
;   fullprog_bss
;   ...  ; Uninitialized data like: `myvar: resw 1' here.
;   fullprog_end [stack_size]
;
; Compilation (assembling): nasm -f bin -o myexe.exe myexe.nasm
;
; Disassembling: ndisasm -b 16 -e 26 -o 10 myexe.exe
;
; At startup, ds:0 and ss:0 are the data, cs:ip is the code (ip is typically
; 10 after fullprog_code), ss:sp is the top of stack (grows downwards).
; At startup, es:0 is the PSP, command-line arguments are
; at es:0x80.
; At startup, flags (e.g. d) and registers ax, bx, cx, dx, si, di and bp are
; not initialized.
; At exit, must pop back stuff it pushed to the stack.
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
section .text align=1 vstart=-0x10
; DOS .exe header, similar to: https://stackoverflow.com/q/14246493/97248
exe_header:
db 'MZ'  ; Signature.
dw ((code_end-exe_header)+(data_end-data_start))&511  ; Image size low 9 bits.
dw ((code_end-exe_header)+(data_end-data_start)+511)>>9  ; Image size high bits, including header and relocations (none here), excluding .bss, rounded up.
dw call__fullprog_end*0  ; Relocation count.
dw 1  ; Paragraph (16 byte) count of header. Points to code_startseg.
dw (bss_end-bss_start+15-(-((data_end-data_start)+(code_end-code_startseg))&15))>>4  ; Paragraph count of minimum required memory.
dw 0xffff  ; Paragraph count of maximum required memory.
dw (code_end-code_startseg)>>4  ; Stack segment (ss) base, will be same as ds. Low 4 bits are in vstart= of .data.
code_startseg:
dw (bss_end-bss_start)+(data_end-data_start) ; Stack pointer (sp).
dw 0  ; No file checksum.
dw code_start-code_startseg  ; Instruction pointer (ip): 8.
dw 0  ; Code segment (cs) base.
; We reuse the final 4 bytes of the .exe header (dw relocation_table_ofs,
; overlay_number) for code.
code_start:
push ss
pop ds
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
mov ax, 0x4c00  ; EXIT, exit code in al; `ret' in .com files doesn't work in .exe files.
int 0x21
%endif
code_end:
; Fails with `error: TIMES value -... is negative' if code is too large (>~64 KiB).
times -((code_end-code_startseg)>>16) db 0
section .data align=1 vstart=((code_end-code_startseg)&15)
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
stack: resb %1
bss_end:
call__fullprog_end:  ; Make fullprog_code without fullprog_end fail.
; Fails with `error: TIMES value -... is negative' if data is too large (>~64 KiB).
times -(((bss_end-bss_start)+(data_end-data_start))>>16) db 0
%endmacro

; Autodetects stack size to fill data segment to 65535 bytes.
%macro fullprog_end 0
fullprog___check_end
auto_stack:  ; Autodetect stack size to fill data segment to 65535 bytes.
fullprog_end 65535-((auto_stack-bss_start)+(data_end-data_start))
%endmacro
