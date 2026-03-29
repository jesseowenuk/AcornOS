org 0x7C00
bits 16

code_start:
    ; disable interrupts with cli so we don't get interrupted and jump to 0x0000 
    cli
    jmp 0x0000:initialise_cs

initialise_cs:
    ; set all the segments to 0x0000 and the stack pointer to the start of the bootloader code,
    ; this grows downwards so is fine here. Finally we re-enable interrupts with sti
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; save the drive number for later
    mov byte [drive_number], dl

halt:
    hlt
    jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drive_number db 0

times 510-($-$$) db 0
dw 0xaa55