org 0x7C00
bits 16

halt:
    hlt
    jmp halt

times 510-($-$$) db 0
dw 0xaa55