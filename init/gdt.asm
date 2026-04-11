kernel_gdt:
    ; GDT size
    dw .kernel_gdt_end - .kernel_gdt_start - 1
    dd .kernel_gdt_start

.kernel_gdt_start:

.kernel_gdt_null:
    dw 0x0000                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 00000000b                ; access
    db 00000000b                ; granularity
    db 0x00                     ; base (high 8 bits) 

.kernel_gdt_protected_code:
    dw 0x07FF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10011010b                ; access
    db 11001111b                ; granularity
    db 0x00                     ; base (high 8 bits)
    
.kernel_gdt_protected_data:
    dw 0x07FF                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 10010010b                ; access
    db 11001111b                ; granularity
    db 0x00                     ; base (high 8 bits)

.kernel_gdt_unused:
    dw 0x0000                   ; limit
    dw 0x0000                   ; base (low 16 bits)
    db 0x00                     ; base (mid 8 bits)
    db 00000000b                ; access
    db 00000000b                ; granularity
    db 0x00                     ; base (high 8 bits)

    ; we're going to fill the rest of the GDT to 256 bytes (32 entries)
    ; for use later
    times 252 dq 0x0
.kernel_gdt_end: