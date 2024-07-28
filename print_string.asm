;
; print_string.asm
; 16-bit string printing
;
bits 16
    ;------------------------------------------------------------------
    ; print_string
    ; Subroutine to print strings in 16-bit mode
    ;------------------------------------------------------------------
    ; Usage:
    ;   mov si, string to print
    ;   call print_string
    ;------------------------------------------------------------------
print_string:
    pusha                           ; save the registers in case they're needed later
    mov ah, 0x0e                    ; ah 0x0e = tele-type
    
print_string_loop:    
    lodsb                           ; loads the next character from SI register into AL and increments to next character
    cmp al, 0                       ; if AL == 0 (end of string character) then
    je print_string_done            ;   YES - end of string so we're done - jump to the end 
    int 0x10                        ; else - call interrupt 0x10 to print out the character now in AL register
    jmp print_string_loop           ; else jump back to the beginning of print_string

print_string_done:
    popa                            ; restore the registers so we don't break anything
    ret                             ; return to where we were called from   