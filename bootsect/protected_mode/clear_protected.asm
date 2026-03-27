;
; clear_protected.asm
;
; Routine to clear the screen in protected mode
;

clear_protected:
    pusha

    mov ebx, vga_memory
    mov ecx, vga_start
    mov edx, 0

    .loop:
        cmp edx, ebx
        jge .done

        push edx

        ; Put the space and attribute into AX
        mov al, ' '
        mov ah, vga_attribute

        ; Move forward 2 bytes to the next 
        ; character & attribute byte, then
        ; write a space character with the 
        ; attribute.
        add edx, ecx
        mov word[edx], ax

        pop edx

        add edx, 2

        jmp .loop

    .done:
        popa
        ret