;
; SETUP_ID
;
; Sets up an IDT with 256 entries pointing to
; ignore_int, interrupt gates. It then loads
; idt. Everything that wants to install itself
; in the idt-table may do so themselves. Interrupts
; are enabled elsewhere, when we can be relatively 
; sure everything is OK. This routine will be
; overwritten by the page tables.
;

setup_idt:
    lea edx, [ignore_int]
    mov ecx, 256
    lea edi, [_idt]

.fill:
    mov eax, edx

    mov word [edi], ax              ; offset 0-15
    mov word [edi+2], 0x08          ; selector
    mov byte [edi+4], 0
    mov byte [edi+5], 0x8E          ; type
    shr eax, 16
    mov word [edi+6], ax            ; offset 16-31

    add edi, 8
    loop .fill

    lidt [idt_descriptor]
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFAULT INTERRUPT HANDLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 2
ignore_int:
    inc byte [0xb8000 + 160]
    mov byte [0xb8000 + 161], 2
    iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
idt_descriptor:
    dw (256 * 8) - 1
    dd _idt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDT Table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_idt:
    times 256 dq 0