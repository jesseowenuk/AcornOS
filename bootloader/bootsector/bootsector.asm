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

    ; print out a loading message
    mov si, loading_message
    call simple_print

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LOAD STAGE 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    mov si, stage2_message
    call simple_print

    ; read 7 sectors (our stage 2) and put them in memory at 0x7e00 
    ; (right after our bootloader code in memory)
    mov ax, 1
    mov ebx, 0x7e00
    mov cx, 1
    call read_sectors

    jc error

    mov si, done_message
    call simple_print

    jmp 0x7e00

error:
    mov si, error_message
    call simple_print

halt:
    hlt
    jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loading_message         db 13, 10, 'AcornOS Bootloader', 13, 10, 10, 0
stage2_message          db 'Stage 1: Loading Stage 2', 0
done_message            db '  [DONE]', 13, 10, 0
error_message           db 13, 10, 'Error, AcornOS boot halted.', 0

drive_number db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BOOTSECTOR INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'simple_print.asm'
%include 'disk.asm'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PADDING & MAGIC NUMBER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 510-($-$$) db 0
dw 0xaa55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STAGE 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Load stage 3
    mov ax, 2
    mov ebx, 0x8000
    mov cx, 6
    call read_sectors

    jc error

; Enable A20
    call enable_a20 
    jc error

; Load the GDT
    lgdt [gdt]

    hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STAGE 2 INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'a20.asm'
%include 'gdt.asm'