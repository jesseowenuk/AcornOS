bios_print:

    ; ******************************************
    ;	Prints a string using the BIOS
	; ******************************************

	; IN 
	; SI = points to a 0x00 terminated string

	push ax							; save registers
	push si
	mov ah, 0x0E					; int 0x10 function 0x0E (print character)

	.loop:
		lodsb						; load character from string
		test al, al					; Is it the null terminator?
		jz .done					; If so - we're done
		int 0x10					; Call the BIOS to do our bidding
		jmp .loop					; repeat!

	.done:
		pop si						; Restore the registers
		pop ax
		ret