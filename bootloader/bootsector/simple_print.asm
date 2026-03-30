simple_print:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; SIMPLE_PRINT
    ; *************
    ; Prints a string using the BIOS print interrupt 0x10, AH=0x0E
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; IN
    ;   * SI -> points to a null (0x00) terminated string
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; Save the registers
    push ax
    push si

    ; int 0x10, AH=0x0E, AL=character -> prints the character in AL
    mov ah, 0x0E

.loop:
    ; load the next character pointed at by SI into AL
    lodsb

    ; is the character now in AL the 0x00 terminator?
    test al, al

    ; if it is (zero flag set from above test opcode) then we're done
    jz .done

    ; call BIOS
    int 0x10

    ; and we go again
    jmp .loop

.done:
    ; restore the registers
    pop si
    pop ax

    ; and we're done so return from whence we came!
    ret
