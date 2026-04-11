;
; HEAD.ASM
;
; This file contains the 32-bit startup code.
;

extern stack_start
global startup_32

startup_32:
    ;mov eax, 0x0
    ;mov ds, eax
    ;mov es, eax
    ;mov fs, eax
    ;mov gs, eax

    lgdt[kernel_gdt]
  
    lss esp, [stack_start]

    hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'gdt.asm'