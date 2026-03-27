;
; clear_long.asm
;
; Routine to clear the screen in 64-bit long mode
;

clear_long:
    push rdi
    push rax
    push rcx

    mov rdi, 0x07

    shl rdi, 8
    mov rax, rdi

    mov al, ' '

    mov rdi, 0x000B8000
    mov rcx, vga_memory / 2

    rep stosw

    pop rcx
    pop rax
    pop rdi
    ret