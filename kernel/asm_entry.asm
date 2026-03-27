;
; entry.asm
;
; The assembly entry point for our kernel
;

bits 64
extern main

section .text
global _start

_start:
    call main
    hlt