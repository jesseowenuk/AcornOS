extern bss_start
extern bss_end
extern kernel_entry

global _start
_start:
    cld

    ;------------------------------------------------------------------
    ; Zero out the BSS section
    ;------------------------------------------------------------------
    xor al, al
    mov edi, bss_start
    mov ecx, bss_end
    sub ecx, bss_start
    rep stosb

    

    call kernel_entry