;
; bootsect.asm
;
; A bootsector which displays the letter 
; 'A' for Acorn :-)
;

start:
    mov ah, 0x0e
    mov al, 'A'
    int 0x10

end:
    hlt

times 510 - ($-$$) db 0
dw 0xaa55