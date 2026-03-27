;
; print_protected
;
; routine to print messages in 32-bit
;
; IN:
;   ESI = Start of string to print
;
print_protected:
    pusha
    mov edx, 0x000B8000

    .loop:
        cmp byte[esi], 0
        je .done

        mov al, byte[esi]                       ; Put the next character in AL
        mov ah, 0x0F                            ; And the style in AH
        mov word[edx], ax                       ; And print the character out

        ; Increment the registers
        add esi, 1
        add edx, 2

        jmp .loop

    .done:
        popa
        ret