;
; A simple boot sector program that loops forever.
;

loop:                               ; Define a label "loop" for an address that we can jump back to

    jmp loop                        ; Use jmp CPU instruction to jump back to the address of the 
                                    ; "loop" instruction, which is the current instruction.

times 510 - ($ - $$) db 0           ; Fill file with zero values up through 510th byte.
dw 0xAA55                           ; Write 0xAA55 to bytes 511 and 512 so we can boot.