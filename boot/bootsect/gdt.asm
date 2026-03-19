GDT:
    dw .GDT_end - .GDT_start - 1            ; Calculate the size of the GDT
    dd .GDT_start                           ; the start of the GDT

    .GDT_start:
        ; Null descriptor (this segment is required to be null)
        .null_descriptor:
            dw 0x0000                       ; Limit
            dw 0x0000                       ; Base (the low 16 bits)
            db 0x00                         ; Base (mid 8 bits)
            db 00000000b                    ; Access
            db 00000000b                    ; Granulatity
            db 0x00                         ; Base (high 8 bits)

        ; Unreal code
        .unreal_code:
            dw 0xFFFF                       ; Limit
            dw 0x0000                       ; Base (the low 16 bits)
            db 0x00                         ; Base (mid 8 bits)
            db 10011010b                    ; Access
            db 10001111b                    ; Granulatity
            db 0x00                         ; Base (high 8 bits)

        ; Unreal data
        .unreal_data:
            dw 0xFFFF                       ; Limit
            dw 0x0000                       ; Base (the low 16 bits)
            db 0x00                         ; Base (mid 8 bits)
            db 10010010b                    ; Access
            db 10001111b                    ; Granulatity
            db 0x00                         ; Base (high 8 bits)

        ; Protected Mode Code
        .protected_mode_code:
            dw 0xFFFF                       ; Limit
            dw 0x0000                       ; Base (the low 16 bits)
            db 0x00                         ; Base (mid 8 bits)
            db 10011010b                    ; Access
            db 11001111b                    ; Granulatity
            db 0x00                         ; Base (high 8 bits)

        ; Protected Mode Data
        .protected_mode_data:
            dw 0xFFFF                       ; Limit
            dw 0x0000                       ; Base (the low 16 bits)
            db 0x00                         ; Base (mid 8 bits)
            db 10010010b                    ; Access
            db 11001111b                    ; Granulatity
            db 0x00                         ; Base (high 8 bits)

    .GDT_end: