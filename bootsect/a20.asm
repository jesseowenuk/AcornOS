;
; a20.asm
; Functions to enable the A20 line
;

;
; check_a20_line
;
; Function to check the status of the A20 line
;
; OUT
;   AX = 0 if the A20 is disabled (memory wraps around)
;   AX = 1 if the A20 is enabled (memory does not wrap around)
;

check_a20_line:
    pushf
    push ds
    push es
    push di
    push si

    cli

    xor ax, ax
    mov es, ax                  ; ES == 0x0000

    not ax      
    mov ds, ax                  ; DS == 0xFFFF

    mov al, byte [es:di]
    push ax                     ; Put the value in ES:DI onto the stack

    mov al, byte [ds:si]
    push ax                     ; Put the value in DS:SI onto the stack

    mov byte [es:di], 0x00      ; Move 0x00 into ES:DI
    mov byte [ds:si], 0xFF      ; Move 0xFF into DS:SI

    cmp byte [es:di], 0xFF      ; does value in ES:DI == 0xFF (if so it's wrapped around
                                ; and the A20 is therefore not enabled)

    ; restore registers
    pop ax 
    mov byte [ds:si], al

    pop ax 
    mov byte [es:di], al

    mov ax, 0
    je .exit

    mov ax, 1

    .exit:
        pop si
        pop di
        pop es
        pop ds
        popf

        ret