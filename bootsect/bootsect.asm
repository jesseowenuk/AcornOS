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

org 0x7c00

start:
    mov si, message
    call print_string

end:
    hlt

;
; print_string
;
; Prints a C style null terminating string
; IN:
;   SI = points to the first character of the string
;
print_string:
    push ax
    mov ah, 0x0e

    .loop:
        lodsb
        cmp al, 0
        je .done
        int 0x10
        jmp .loop

    .done:
        pop ax
        ret

message db 13, 10, 'Hello from Acorn Boot!', 13, 10, 0

times 510 - ($-$$) db 0
dw 0xaa55