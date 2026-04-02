gdt:
    ; GDT size
    dw .gdt_end - .gdt_start - 1
    dd .gdt_start

.gdt_start:

.gdt_null:
    dw 0x0000                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 00000000b                ; access
    db 00000000b                ; granularity
    db 0x00                     ; base (high 8 bits)

.gdt_unreal_code:
    dw 0xFFFF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10011010b                ; access
    db 10001111b                ; granularity
    db 0x00                     ; base (high 8 bits)

.gdt_unreal_data:
    dw 0xFFFF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10010010b                ; access
    db 10001111b                ; granularity
    db 0x00                     ; base (high 8 bits)  

.gdt_protected_code:
    dw 0xFFFF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10011010b                ; access
    db 11001111b                ; granularity
    db 0x00                     ; base (high 8 bits)
    
.gdt_protected_data:
    dw 0xFFFF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10010010b                ; access
    db 11001111b                ; granularity
    db 0x00                     ; base (high 8 bits)

.gdt_end: