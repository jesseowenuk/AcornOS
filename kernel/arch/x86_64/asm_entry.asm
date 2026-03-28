;
; entry.asm
;
; The assembly entry point for our kernel
;

bits 64
extern main
extern _init

section .bss
align 16
stack_bottom:
buffer resb 16386     ; reserves 16 KiB for the stack
stack_top:

section .text
global _start

_start:
    mov rsp, stack_top

    call _init

    call main
    hlt