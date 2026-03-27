;
; gdt.asm
; Our 64-bit Global Descriptor Table
;

;
; We'll define this as a flat model for now as this allows
; us to read and write code anywhere! :-)
;

align 4

gdt_start64:
    ; First we have the null sector (this is required as a memory
    ; integrity check)
    gdt_null_descriptor64:
        dd 0x00000000
        dd 0x00000000

    ; This is defining the code sector for 64-bit
    gdt_code_descriptor64:
        ; Base: 0x00000
        ; Limit: 0xFFFFF
        ; 1st set of flags: 0b1001
        ;   Present: 1
        ;   Privelege: 00
        ;   Descriptor: 1
        ; Type flags: 0b1010
        ;   Code: 1
        ;   Conforming: 0
        ;   Readable: 1
        ;   Accessed: 0
        ; 2nd set of flags: 0b1010
        ;   Granularity: 1
        ;   32-bit default: 0
        ;   64-bit segment: 1
        ;   AVL: 0
        dw 0xFFFF               ; Limit (bits 0-15)
        dw 0x0000               ; Base (bits 0-15)
        db 0x00                 ; Base (bits 16-23)
        db 0b10011010           ; 1st flags and type flags
        db 0b10101111           ; 2nd flags, Limit (bits 16-19)
        db 0x00                 ; Base (bits 24-31)

    ; This is defining the data sector for 64-bit
    gdt_data_descriptor64:
        ; Base: 0x0000
        ; Limit: 0xFFFF
        ; 1st flags: 0b1001
        ;   Present: 1
        ;   Privelege: 00
        ;   Descriptor: 1
        ; Type flags: 0b0010
        ;   Code: 0
        ;   Expand down: 0
        ;   Writable: 1
        ;   Accessed: 0
        ; 2nd flags: 0b1010
        ;   Granularity: 1
        ;   32-bit default: 0
        ;   64-bit segmemt: 1
        ;   AVL: 0
        dw 0xFFFF       ; Limit (bits 0-15)
        dw 0x0000       ; Base (bits 0-15)
        db 0x00         ; Base (bits 16-23)
        db 0b10010010   ; 1st flags, type flags
        db 0b10100000   ; 2nd flags, Limit (bits 16-19)
        db 0x00         ; Base (bits 24-31)
    
gdt_end64:

; Here is the descriptor we'll need to provide so the above can be loaded.
; It provides a pointer to the GDT and the size
gdt_descriptor64:
    dw gdt_end64 - gdt_start64 - 1              ; The size of the GDT - 1
    dd gdt_start64                              ; Points to the start of the GDT   

; Finally these point to the code and data segments which 
; will help us jump to the right place later
code_segment_64    equ gdt_code_descriptor64 - gdt_start64
data_segment_64    equ gdt_data_descriptor64 - gdt_start64

