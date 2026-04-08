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

    jc error_reading_disk

    mov si, done_message
    call simple_print

    jmp 0x7e00

error_reading_disk:
    mov si, error_message_disk
    call simple_print

error_enabling_a20:
    mov si, error_message_a20
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
error_message_disk      db 13, 10, 'Error reading disk, AcornOS boot halted.', 0
error_message_a20       db 13, 10, 'Error enabling a20, AcornOS boot halted.', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BOOTSECTOR INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'simple_print.asm'
%include 'disk.asm'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPACE FOR MBR PARTITON TABLE, PADDING & MAGIC NUMBER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 0x1b8-($-$$) db 0 
times 510-($-$$) db 0
dw 0xaa55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STAGE 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Load stage 3
    mov ax, 2
    mov ebx, 0x8000
    mov cx, 62
    call read_sectors

    jc error_reading_disk

; Enable A20
    call enable_a20 
    jc error_enabling_a20

; re-program the 8259 - put them right after the intel-reserved
; hardware interrupts at int 0x20-0x2f

    ; start with initialisation sequence
    mov al, 0x11
    out 0x20, al
    out 0xA0, al

    ; new start address of the hardware interrupts (chip 1)
    mov al, 0x20
    out 0x21, al
    
    ; new start address of the hardware interrupts (chip 2)
    mov al, 0x28
    out 0xA1, al

    ; 8259-1 is master
    mov al, 0x04
    out 0x21, al

    ; 8259-2 is slave
    mov al, 0x02
    out 0xA1, al

    ; 8086 mode for both
    mov al, 0x01
    out 0x21, al
    out 0xA1, al

    ; mask off all the interrupts for now
    mov al, 0xFF
    out 0x21, al
    out 0xA1, al

; Load the GDT
    lgdt [gdt]

; Disable interrupts
    cli

; Move into protected mode and jump to 32-bit code!
    mov eax, cr0
    or eax, 00000001b
    mov cr0, eax

    jmp 0x18:protected_mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STAGE 2 INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'a20.asm'
%include 'gdt.asm'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROTECTED MODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bits 32
protected_mode:
    ; load the segments with the protected mode code segment
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FILE PADDING
; ************
; This ensures we're padded enough so that the binary from
; the C file is aligned to the start of the right sector.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 1024-($-$$) db 0