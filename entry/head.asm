;
; HEAD.ASM
;
; This file contains the 32-bit startup code.
;

startup_32:
    mov eax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    hlt