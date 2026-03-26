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

    call load_sector
    jc .disk_error

    mov si, done_message
    call print_string

    .disk_error:
        mov si, disk_error_message
        call print_string

end:
    hlt

;
; load_sector
; Loads a single sector from disk using CHS addressing
;
; IN
;   ES = Segment of where to put the buffer
;   BX = Offset of where to put the buffer (together these become ES:BX)
;   DL = drive (BIOS will put the value we need in here)
;
; OUT
;   Carry set on error
;
; BIOS Reading Sectors (CHS)
;   AH = 0x02
;   AL = total sector count to read (must be no more than 127 and cannnot be 0)
;   CH = cylinder (0-1023)
;   CL = First sector to read
;   DH = Head (0-15)
;   ES:BX = where to put the bytes read
;   DL = drive number (BIOS will provide this already provides this in the right place :))
;   int 0x13
load_sector:
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 0
    mov dh, 0
    int 0x13

    .done:
        pop dx
        pop cx
        pop bx
        pop ax
        ret

;
; Real Mode Includes *************************************************************
;
%include 'print_string.asm'

;
; Data ***************************************************************************
;
loading_message db 13, 10, 'Loading Sectors...', 0
disk_error_message db '[ERROR]'
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

times 1024-($-$$) db 0
