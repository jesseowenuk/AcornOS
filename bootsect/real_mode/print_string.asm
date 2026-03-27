;
; print_string.asm
;
; BIOS Teletype Info:
;   AH = 0x0e
;   AL = character to print
;   int 0x10
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