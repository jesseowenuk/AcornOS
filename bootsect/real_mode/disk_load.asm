;
; disk_load.asm
; Real mode disk loading functions
;

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
;   CL = First sector to read (starts from 1!)
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
    mov al, 4
    mov ch, 0
    mov cl, 2
    mov dh, 0
    int 0x13

    .done:
        pop dx
        pop cx
        pop bx
        pop ax
        ret