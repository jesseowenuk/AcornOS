;
; load_gdt.asm
; The GDT is in this file plus the code to load it
;
bits 16

load_gdt:
    cli                             ; disable interrupts whilst we load the GDT
    pusha
    lgdt [gdt_descriptor]           ; load up our GDT into the GDT register
    sti 
    popa
    ret

gdt_data:
    ; null segment
    dd 0                            ; define 8 bytes with 0 (required)
    dd 0

    ; code segment
    dw 0FFFFh                      ; limit low (max address for our segment)
    dw 0                            ; base low 
    db 0                            ; base middle
    db 10011010b                    ; Access byte 
    db 11001111b                    ; Granularity byte
    db 0                            ; last part of the base address

    ; data segment
    dw 0FFFFh                       ; segment limit
    dw 0                            ; base address
    db 0                            ; base middle
    db 10010010b                    ; Access byte
    db 11001111b                    ; Granularity byte
    db 0                            ; last part of the base address

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_data - 1
    dd gdt_data