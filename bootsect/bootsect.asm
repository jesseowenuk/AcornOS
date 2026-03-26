;
; bootsect.asm
;
; A bootsector which displays a welcome mesage
; using our new print_string routine.
;

org 0x7c00
bits 16

start:
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

    hlt

times 1024-($-$$) db 0
