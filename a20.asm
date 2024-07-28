;
; a20.asm
; A simple subroutine to enable A20 via the keyboard controller
;
bits 16

enable_a20:
    pusha
    cli                         ; disable interrupts

    call wait_for_io_1          ; wait for input buffer to be empty
    mov al, 0xAD                ; command to disable the keyboard
    out 0x64, al                ; send this via port 0x64 to the keyboard controller

    call wait_for_io_1          ; wait for input buffer to be empty
    mov al, 0xD0                ; command to read the command byte
    out 0x64, al                ; send this via port 0x64 to the keyboard controller

    call wait_for_io_2          ; wait for the output buffer to be full
    in al, 0x60                 ; read command byte from the keyboard controller
    push eax                     ; push this onto the stack

    call wait_for_io_1          ; wait for input buffer to be empty
    mov al, 0xD1                ; command to load a command byte
    out 0x64, al                ; send this via port 0x64 to the keyboard controller

    call wait_for_io_1          ; wait for input buffer to be empty
    pop eax                      ; restore the original command byte
    or al, 2                    ; set bit 1 to enable the keyboard interface
    out 0x60, al                ; send the value of AL register via port 0x60 -> restore keyboard to what it was before we started

    call wait_for_io_1          ; wait for the input buffer to be empty
    mov al, 0xAE                ; command to re-enable the keyboard interface
    out 0x64, al                ; send this via port 0x64 to the keyboard controller

    call wait_for_io_1          ; wait for the input buffer to be empty
    popa
    sti                         ; enable interrupts
    ret                         ; we're done - return to calling code

wait_for_io_1:
    in al, 0x64                 ; read whatever is on port 0x64 into the AL register
    test al, 2                  ; logical 'and' operation to test AL register against 2 (set if the input buffer is full)
    jnz wait_for_io_1           ; if there's nothing in the input buffer loop back and try again
    ret                         ; we're done - return back to calling code

wait_for_io_2:
    in al, 0x64                 ; read whatever is on port 0x64 into the AL register
    test al, 1                  ; logical 'and' operation to test AL register against 1 (set if the output buffer is full) 
    jz wait_for_io_2           ; is test above is zero jump back to wait_for_io_2
    ret                         ; we're done - return back to calling code
