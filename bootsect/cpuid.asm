;
; cpuid.asm
;
; Gets information about the CPU.
; We'll use it for now to detect if long mode is available
; 

;
; is_long_mode_available
; Function to check if long mode is available on the CPU
; we're running on - checking by asking cpuid
;
; The steps are:
; 1) Check for CPUID
; 2) Check for CPUID extended functions
; 3) Check for long mode support
;

;
; First, lets check if CPUID is even available.
; We do this by checking for the existence of a
; single bit in the FLAGS register - as we can't
; read it directly, we'll push it onto the stack
; and then pop it into EAX.
;
; The bit we're looking for is bit 21, if CPUID
; is not supported this bit will take on a particular
; value, otherwise it will take on the value we set it
; to.
;
is_long_mode_available:
    pushad

    pushfd
    pop eax                         ; Grab a copy of the flags register and put it into EAX
    mov ecx, eax                    ; and save it for later

    xor eax, 1 << 21                ; Flip the ID bit (21st bit of the flags register)
    push eax                        ; Write this back to the flags register by pushing the revised flags onto the stack
    popfd                           ; and then poping them back into the register

    ; Now we need to read them back to see if the flipped bit has remained flipped
    pushfd
    pop eax

    ; We now have everything we need to check so restore the saved version of the flags (currently in ECX)
    push ecx
    popfd

    ; Now we check if the 21st bit remained flipped
    ; If they are equal the bit got flipped back during copy so CPUID not supported
    cmp eax, ecx
    je .cpuid_not_found

    ; If we got here CPUID is available - yay!
    ; So we can move on to check if the extended functions are available
    ;
    ; To check for extended features we set EAX to 0x80000000 
    ; to ask how many features are supported. If extended features exist, 
    ; the returned value in EAX will be greater than 0x80000000.
    ; Otherwise it will stay the same.
    mov eax,  0x80000000
    cpuid 
    cmp eax,  0x80000001
    jb .cpuid_not_found

    ; If we get here we can finally check for the presence of long mode.
    ;
    ; If long mode is supported CPUID will set the 29th bit of register
    ; EDX to  0x80000001.
    mov eax,  0x80000001
    cpuid
    test edx, 1 << 29
    jz .long_mode_not_found

    .end:
        popad
        ret
        
    .cpuid_not_found:
        call clear_protected
        mov esi, cpuid_not_found_message
        call print_protected
        hlt

    .long_mode_not_found:
        call clear_protected
        mov esi, long_mode_not_found_message
        call print_protected
        hlt

cpuid_not_found_message db 'Checking for CPUID support [NOT SUPPORTED]', 0
long_mode_not_found_message db 'Checking for long mode support [NOT SUPPORTED]', 0