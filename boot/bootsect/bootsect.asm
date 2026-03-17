org 0x7C00
bits 16

code_start:
    cli
    jmp 0x0000:init_cs

init_cs:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov byte [drive_number], dl

    mov si, message_loading
    call bios_print

; ************** Load stage 2 ***********************

mov si, message_stage2
call bios_print

mov ax, 1
mov ebx, 0x7e00
mov cx, 7
call read_sectors

jc err

mov si, message_done
call bios_print

jmp 0x7e00

err:
    mov si, message_error
    call bios_print

halt:
    jmp halt

; Data

message_loading      db 13, 10, 'Acorn Boot', 13, 10, 10, 0
message_stage2       db 'stage1: Loading stage2...', 0
message_error        db 13, 10, 'Error.', 0
message_done         db '   DONE', 13, 10, 0


; Includes

%include 'bios_print.asm'
%include 'disk.asm'

drive_number db 0

times 510-($-$$) db 0
dw 0xaa55