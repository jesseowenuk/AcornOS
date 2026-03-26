;
; bootsect.asm
;
; A bootsector which displays a welcome mesage
; using our new print_string routine.
;

org 0x7c00
bits 16

start:
    ; Set up the stack pointer and base pointer
    ; The stack moves downwards so it's fine to 
    ; put it at the start of our bootloader!
    mov bp, 0x7c00
    mov sp, bp

    mov si, loading_message
    call print_string

    mov bx, 0x7e00
    call load_sector
    jc .disk_error

    mov si, done_message
    call print_string

    mov si, stage2_message
    call print_string

    jmp 0x7e00

    .disk_error:
        mov si, disk_error_message
        call print_string
        jmp end

end:
    hlt

;
; Real Mode Includes *************************************************************
;
%include 'print_string.asm'
%include 'disk_load.asm'
%include 'gdt.asm'

;
; Data ***************************************************************************
;
loading_message db 13, 10, 'Loading Sectors...', 0
stage2_message db 13,10, 'Jumping to stage 2...', 0
disk_error_message db '[ERROR]', 0
done_message db '[DONE]', 0

;
; Padding & Magic Number *********************************************************
;
times 510 - ($-$$) db 0
dw 0xaa55

;
; Stage 2 ************************************************************************
;
stage2:
    mov si, done_message
    call print_string

    ; We start moving into protected mode here!!!!
    ; We need to:
    ;   Disable interrupts
    ;   Load the GDT (found in gdt.asm)
    ;   Enable protected mode via the cr0 register
    ;   Far jump into the 32-bit code segment to flush the pipeline and
    ;   enter 32-bit protected mode!
    ; Here we go.....

    ; disable the interrupts
    cli

    ; that was easy, next load the GDT
    mov si, gdt_loaded_message
    call print_string

    lgdt [gdt_descriptor32]

    mov si, done_message
    call print_string

    ; Enable protected mode via the protection
    ; enable bit in the cr0 register
    mov si, protected_mode_switch_message
    call print_string

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    hlt

; Stage 2 Data ************************************************
gdt_loaded_message db 13, 10, 'Loading GDT...', 0
protected_mode_switch_message db 13, 10, 'Enabling Protected Mode...', 0

times 1024-($-$$) db 0
