is_a20_enabled:

    ;**********************************************
    ;   Checks if the A20 address line is enabled
    ; *********************************************

    ; OUT 
    ; Carry if disabled, cleared if enabled

    push ax                             ; save those registers so we can restore later
    push bx
    push es
    push fs

    xor ax, ax                          ; Set ES to zero
    mov es, ax
    not ax                              ; Set FS to 0xFFFF by flipping the bits in AX
    mov fs, ax                          ; and moving them into FS

    mov ax, word [es:0x7DFE]            ; check using the boot signature
    cmp word [fs:0x7E0E], ax            ; If A20 is disabled, this should be the
                                        ; same address as the boot signature
    je .value_changed                   ; If they are equal, we check again with a different value

    .enabled:
        clc                             ; If we land here the A20 is enabled so clear the carry flag and 
        jmp .done                       ; lets get out of here...

    .value_changed:
        mov word [es:0x7DFE], 0x1234    ; Change the value of 0000:7DFE to 0x1234
        cmp word [fs:0x7E0E], 0x1234    ; Is 0xFFFF:7E0E changed as well?
        jne .enabled                    ; If it is the A20 is enabled - see ya!

        stc                             ; If we've got here the A20 is not enabled which means we have work to do

    .done:
        mov word [es:0x7DFE], ax        ; Put the boot signature back
        pop fs                          ; Put the registers back as we found them
        pop es
        pop bx
        pop ax
        ret                             ; And return to the calling code

enable_a20:
    ; ***************************************
    ;   Tries to enable the A20 address line
    ; ***************************************

    ; OUT:
    ; The carry is cleared if success, it will be set if we failed

    push eax                            ; save registers

    call is_a20_enabled                 ; First lets check if the a20 is already enabled
    jnc .done                           ; if it is we don't need to do any more

    mov ax, 0x2401                      ; First we'll try to use BIOS to enable the A20
    int 0x15

    call is_a20_enabled                 ; Lets see if this simple method worked
    jnc .done                           ; if it did - once agaib we're done

    .enable_a20_via_keyboard:
        cli                             ; Time to ignore the interrupts

        call .wait_for_a20              ; This time we're going to try to use the keyboard controller
        mov al, 0xAD                    ; to enable the A20 gate
        out 0x64, al                    

        call .wait_for_a20
        mov al, 0xD0
        out 0x64, al

        call .wait_for_a20_2
        in al, 0x60
        push eax

        call .wait_for_a20
        mov al, 0xD1
        out 0x64, al

        call .wait_for_a20
        pop eax
        or al, 2
        out 0x60, al

        call .wait_for_a20
        mov al, 0xAE
        out 0x64, al

        call .wait_for_a20
        sti                             ; Get those interrupts enabled again

        jmp .a20_keyboard_done

        .wait_for_a20:
            in al, 0x64
            test al, 2
            jnz .wait_for_a20
            ret

        .wait_for_a20_2:
            in al, 0x64
            test al, 1
            jz .wait_for_a20_2
            ret

        .a20_keyboard_done:
        
        call is_a20_enabled                 ; is A20 enabled now?

        ; We've done all we can so quit the routine here 
        ; the carry flag will be forwarded to the caller

        .done:
            pop eax
            ret
     