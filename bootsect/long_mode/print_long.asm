;
; print_long.asm
;
; Function to print a C like null terminated string
;

print_long:
    push rax
    push rdx
    push rdi
    push rsi

    mov rdx, 0x000B8000
    mov rdi, 0x07
    shl rdi, 8

    .loop:
        cmp byte[rsi], 0
        je .done

        ; Handle strings that are too long
        cmp rdx, vga_start + vga_memory
        je .done

        ; Move character to AL and the style to AH
        mov rax, rdi
        mov al, byte[rsi]

        ; Write the above bytes to video memory
        mov word[rdx], ax

        ; Increment registers
        add rsi, 1
        add rdx, 2

        jmp .loop

        .done:
            pop rsi
            pop rdi
            pop rdx
            pop rax

            ret

