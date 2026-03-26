;
; bootsect.asm
;
; A bootsector which displays a welcome mesage
; using our new print_string routine.
;
; BIOS Teletype Info:
;   AH = 0x0e
;   AL = character to print
;   int 0x10
;

org 0x7c00
bits 16

start:
    mov si, message
    call print_string

end:
    hlt

;
; Real Mode Includes *************************************************************
;
%include 'print_string.asm'

;
; Data ***************************************************************************
;
message db 13, 10, 'Hello from Acorn Boot!', 13, 10, 0

;
; Padding & Magic Number *********************************************************
;
times 510 - ($-$$) db 0
dw 0xaa55