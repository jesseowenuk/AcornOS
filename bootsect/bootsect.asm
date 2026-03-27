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
        mov si, error_message
        call print_string
        jmp end

end:
    hlt

;
; Real Mode Includes *************************************************************
;
%include 'real_mode/print_string.asm'
%include 'real_mode/disk_load.asm'
%include 'real_mode/gdt.asm'
%include 'real_mode/a20.asm'

;
; Data ***************************************************************************
;
loading_message db 13, 10, 'Loading Sectors...', 0
stage2_message db 13,10, 'Jumping to stage 2...', 0
a20_enable_message db 13, 10, 'Enabling A20 line...', 0
error_message db '[ERROR]', 0
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
    ;   Enabled A20 line
    ;   Load the GDT (found in gdt.asm)
    ;   Enable protected mode via the cr0 register
    ;   Far jump into the 32-bit code segment to flush the pipeline and
    ;   enter 32-bit protected mode!
    ; Here we go.....

    ; disable the interrupts
    cli

    ; Enable A20 line
    mov si, a20_enable_message
    call print_string  
    call enable_a20

    jc .a20_error
    mov si, done_message
    call print_string
    jmp load_gdt

    .a20_error:
        mov si, error_message
        call print_string
        hlt


load_gdt:
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

    ; Far jump into protected mode
    jmp code_segment:initialise_protected_mode

bits 32
initialise_protected_mode:
    ; We've arrived in 32-bit protected mode - now lets set
    ; things up properly
    mov ax, data_segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; And lets reset the stack to a new location
    mov ebp, 0x90000
    mov esp, ebp

    call clear_protected
    mov esi, protected_done_message
    call print_protected

    call is_long_mode_available
    call clear_protected
    mov esi, long_mode_supported_message
    call print_protected

    call init_page_tables
    call clear_protected
    mov esi, page_tables_message
    call print_protected

    ; switch to 64-bit mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Actually enable the paging now
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Load the 64-bit GDT
    lgdt [gdt_descriptor64]

    ; And... far jump into 64-bit
    ; A bit like with the 32-bit this is to clear CS again
    jmp code_segment_64:initialise_long_mode

; Stage 2 Data ************************************************
gdt_loaded_message db 13, 10, 'Loading GDT...', 0
protected_mode_switch_message db 13, 10, 'Enabling Protected Mode...', 0
protected_done_message db 'Enabling Protected Mode...[DONE]', 0
long_mode_supported_message db 'Checking for long mode support [SUPPORTED]', 0
page_tables_message db 'Creating Page Tables [DONE]', 0

vga_start equ 0x000B8000
vga_memory equ 80 * 25 * 2      ; VGA video memory is 80 columns by 25 rows (we have to times columns by 2 to allow for the character and attribute)
vga_attribute equ 0x07          ; the style we're going to use - 0x07 is the default

; Stage 2 Includes *********************************************

%include 'protected_mode/print_protected.asm'
%include 'protected_mode/clear_protected.asm'
%include 'protected_mode/cpuid.asm'
%include 'protected_mode/init_page_tables.asm'
%include 'protected_mode/gdt.asm'

; Long mode begins here ****************************************
bits 64
initialise_long_mode:
    cli

    mov ax, data_segment_64
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    call clear_long

    mov rsi, long_mode_message
    call print_long

    jmp 0x8400

    hlt

; Long Mode Data *************************************************
long_mode_message db 'Entering 64-bit long mode [DONE]', 0

; Long Mode Includes *********************************************
%include 'long_mode/clear_long.asm'
%include 'long_mode/print_long.asm'

times 2048-($-$$) db 0
