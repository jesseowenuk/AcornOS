a20_check:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; A20_CHECK
    ; **********
    ; Checks if the A20 address line is enabled
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; OUT
    ;   * Carry set <- disabled
    ;   * Carry cleared <- enabled
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the general purpose registers
    push ax
    push bx
    push es
    push fs

    ; Set ES to zero
    xor ax, ax
    mov es, ax

    ; Set FS to 0xFFFF
    not ax
    mov fs, ax

    ; Check using boot signature
    ; If A20 is disabled, this should be the same address as the boot signature
    mov ax, word [es:0x7DFE]
    cmp word [fs:0x7E0E], ax

    ; if they are equal, check again with another value
    je .change_values

.enabled:

    ; If we got here, A20 is enabled so we are done
    ; so clear the carry flag to indicate success and lets
    ; get out of here.
    clc
    jmp .done

.change_values:

    ; Change the value of 0000:7DFE to 0x1234
    ; Then check if FFFF:7E0E has changed as well
    ; If it has changed the A20 is enabled (wrap-around hasn't happened)
    ; so we are done - jump to .enabled
    mov word [es:0x7DFE], 0x1234
    cmp word [fs:0x7E0E], 0x1234
    jne .enabled

    ; If we get here this test failed too so we're definitley not enabled
    ; so set the carry and get out of here.
    stc

.done:

    ; Restore the boot signature and the general purpose registers.
    ; And return.
    ; It's like we were never here...
    mov word [es:0x7DFE], ax
    pop fs
    pop es
    pop bx
    pop ax
    ret

enable_a20:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; ENABLE_A20
    ; **********
    ; Tries to enable the A20 address line
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; OUT
    ;   * Carry cleared <- success
    ;   * Carry set <- failed
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the general purpose registers
    push eax

    ; Before we do anything lets check if the A20 is already enabled
    ; If we're enabled there is nothing more to do so we can return
    ; success.
    call a20_check
    jnc .done

    ; Lets first try to enable via the BIOS
    ; with int 0x15, AX=0x2401
    mov ax, 0x2401
    int 0x15

    ; Let's see if that worked...
    ; If it did - we're done :)
    call a20_check
    jnc .done

.keyboard_method:

    ; We're now going to try to enable the A20 line using the keyboard method
    ; We'll start by disabling interrupts
    cli

    call .a20_wait
    mov al, 0xAD
    out 0x64, al

    call .a20_wait
    mov al, 0xD0
    out 0x64, al

    call .a20_wait2
    in al, 0x60
    push eax

    call .a20_wait
    mov al, 0xD1
    out 0x64, al

    call .a20_wait
    pop eax
    or al, 2
    out 0x60, al

    call .a20_wait
    mov al, 0xAE
    out 0x64, al

    call .a20_wait
    sti

    jmp .keyboard_done

.a20_wait:
    in al, 0x64
    test al, 2
    jnz .a20_wait
    ret

.a20_wait2:
    in al, 0x64
    test al, 1
    jz .a20_wait2
    ret

.keyboard_done:

    ; Well, that was a lot of port writing...
    ; Let's see if it worked!
    call a20_check

    ; We're not trying again now so pass the result of the carry back
    ; to the calling routine

.done:
    pop eax
    ret