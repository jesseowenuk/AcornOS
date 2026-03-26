;
; bootsect.asm
;
; A bootsector which displays the word 
; 'AcornOS' to the screen one character
; at a time.
;
; BIOS Teletype Info:
;   AH = 0x0e
;   AL = character to print
;   int 0x10
;

start:
    ; Enter BIOS teletype mode
    mov ah, 0x0e

    ; Print 'A'
    mov al, 'A'
    int 0x10

    ; Print 'c'
    mov al, 'c'
    int 0x10

    ; Print 'o'
    mov al, 'o'
    int 0x10

    ; Print 'r'
    mov al, 'r'
    int 0x10

    ; Print 'n'
    mov al, 'n'
    int 0x10

    ; Print 'O'
    mov al, 'O'
    int 0x10

    ; Print 'S'
    mov al, 'S'
    int 0x10

end:
    hlt

times 510 - ($-$$) db 0
dw 0xaa55