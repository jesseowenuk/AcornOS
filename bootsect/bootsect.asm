;
; bootsect.asm
;
; Creates a bootable bootsector by writing
; 510 0 bytes and adding the magic number
; 0xaa55 to bytes 511 and 512 so BIOS
; knows we are bootable.
;
; Halts the sytem with the hlt instruction
;

start:
    hlt

times 510 - ($-$$) db 0
dw 0xaa55