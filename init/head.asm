;
; HEAD.ASM
;
; This file contains the 32-bit startup code.
;
extern stack_start
global startup_32

startup_32:
    call setup_idt

    mov byte [0xB8000], 'X'

    hlt
    ;lgdt[kernel_gdt]

    ;jmp dword 0x08:flush

flush:
    hlt
    mov eax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
  
    

    hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'idt.asm'
%include 'gdt.asm'