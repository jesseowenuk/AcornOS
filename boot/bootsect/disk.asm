read_sector:

;
; ******************************************
;   Reads a disk sector with an LBA address
; ******************************************

; IN
; EAX = LBA sector to load
; DL = Drive number
; ES = Buffer segment
; BX = Buffer offset

; OUT
; Carry if error

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    push es
    pop word [.target_segment]
    mov word [.target_offset], bx
    mov dword [.lba_address_low], eax

    xor esi, esi
    mov si, .da_struct
    mov ah, 0x42

    clc                                 ; clear carry for int 0x13 because some BIOS may not clear it on success

    int 0x13                            ; Call int 0x13

    .done:
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
        ret

align 4
.da_struct:
    .packet_size        db 16
    .unused             db 0
	.count				dw 1
	.target_offset		dw 0
	.target_segment		dw 0
	.lba_address_low	dd 0
	.lba_address_high	dd 0

read_sectors:
	; ***************************************
	;	Reads multiple LBA addressed sectors
	; ***************************************

	; IN
	; EAX = LBA starting sector
	; DL = Drive number
	; ES = Buffer segment
	; EBX = Buffer offset
	; CX = Sectors count

	; OUT
	; Carry if error

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	.loop:
		push es
		push ebx

		mov bx, 0x7000					; Load into a temporary buffer
		mov es, bx
		xor bx, bx

		call read_sector				; Read a sector

		pop ebx
		pop es

		jc .done

	push ds

	mov si, 0x7000
	mov ds, si
	mov edi, ebx
	xor esi, esi

	; Put this into the right place in memory
	push ecx
	mov ecx, 512
	a32 o32 rep movsb
	pop ecx

	pop ds

	inc eax						; Increment sector
	add ebx, 512				; Add 512 to the buffer

	loop .loop					; Loop!

	.done:
		pop edi
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret