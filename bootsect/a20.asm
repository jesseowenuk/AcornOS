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

;
; query_a20_support
;
; Function to check if there is A20 support.
;
; OUT
;   AX - A20 support bits (bit 0 = supported on keyboard controller, bit 1 = supported with bit 1 of port 0x92)
;
query_a20_support:
    push bx
    clc

    mov ax, 0x2403
    int 0x15
    jc .error

    test ah, ah
    jnz .error

    mov ax, bx
    pop bx
    ret

    .error:
        stc
        pop bx
        ret

;
; enable_a20_via_keyboard_controller
;
; Function to enable A20 via the 
; keyboard controller.
;
enable_a20_via_keyboard_controller:
    cli

    call .wait_io1
    mov al, 0xad
    out 0x64, al

    call .wait_io1
    mov al, 0xd0
    out 0x64, al

    call .wait_io2
    in al, 0x60
    push eax

    call .wait_io1
    mov al, 0xd1
    out 0x64, al

    call .wait_io1
    pop eax
    or al, 2
    out 0x60, al

    call .wait_io1
    mov al, 0xae
    out 0x64, al

    sti
    ret

    .wait_io1:
        in al, 0x64
        test al, 2
        jnz .wait_io1
        ret

    .wait_io2:
        in al, 0x64
        test al, 1
        jz .wait_io2
        ret

;
; enable_a20
; 
; This routine attempts to enable the A20
; via any means possible
;
; OUT
;   CF - set on error
; 
enable_a20:
    clc                             ; clear the carry flag
    pusha
    mov bh, 0

    call check_a20_line
    jc .enable_a20_fast

    test ax, ax
    jnz .done

    call query_a20_support
    mov bl, al
    test bl, 1                      ; enable A20 using keyboard controller
    jnz .keyboard_controller

    test bl, 2                      ; enable A20 using fast A20 gate
    jnz .enable_a20_fast

    .bios_interrupt:
        mov ax, 0x2401
        int 0x15
        jc .enable_a20_fast
        test ah, ah
        jnz .error
        call check_a20_line
        test ax, ax
        jnz .done

    .enable_a20_fast:
        in al, 0x92
        test al, 2
        jnz .done

        or al, 2
        and al, 0xfe
        out 0x92, al

        call check_a20_line
        test ax, ax
        jnz .done

        test bh, bh                     ; test if there was an attempt using the keyboard controller
        jnz .error

    .keyboard_controller:
        call enable_a20_via_keyboard_controller
        call check_a20_line
        test ax, ax
        jnz .done

        mov bh, 1                       ; flag enable attempt with keyboard controller

        test bl, 2
        jnz .enable_a20_fast
        jmp .error

    .error:
        stc

    .done:
        popa
        ret