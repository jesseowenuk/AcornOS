read_sector:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; READ_SECTOR
    ; *************
    ; Reads a disk sector with an LBA address
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; IN
    ;   * EAX -> LBA sector to load
    ;   * DL -> Drive number
    ;   * ES -> Buffer segment
    ;   * BX -> Buffer offset
    ;
    ; OUT
    ;   * Carry set <- on error
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Populate the disk access packet struct with the buffer to store the bytes we read
    push es
    pop word [.target_segment]
    mov word [.target_offset], bx
    mov dword [.lba_address_low], eax

    ; Get ready to ask the BIOS to read
    xor esi, esi
    mov si, .dap_struct
    mov ah, 0x42

    ; Clear the carry flag so we know if it's set it's definitley because of us! Eep!
    clc

    ; Send it
    int 0x13

.done:
    ; return
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DISK ACCESS PACKET STRUCT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 4
.dap_struct:
    .packet_size        db 16
    .unused             db 0
    .count              dw 1
    .target_offset      dw 0
    .target_segment     dw 0
    .lba_address_low    dd 0
    .lba_address_high   dd 0

read_sectors:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; READ_SECTORS
    ; *************
    ; Reads multiple LBA addressed sectors
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; IN
    ;   * EAX -> LBA starting sector
    ;   * DL -> Drive number
    ;   * ES -> Buffer segment
    ;   * EBX -> Buffer offset
    ;
    ; OUT
    ;   * Carry set <- on error
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the general purpose registers
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

.loop:
    push es
    push ebx

    ; load into a temporary buffer
    mov bx, 0x7000
    mov es, bx
    xor bx, bx

    ; call read sector to read a single sector
    call read_sector

    pop ebx
    pop es

    ; if carry flag is set we've encountered a problem and need to stop
    jc .done

    push ds

    ; Move the sector copied from 0x7000 to the where we actually want it (defined as ES:EBX)
    ; Set the source (SI) and desintation (EDI) registers up for the move
    mov si, 0x7000
    mov ds, si
    mov edi, ebx
    xor esi, esi

    ; Save ECX so we can restore later
    push ecx

    ; Indicate in ECX we are moving 512 bytes
    mov ecx, 512

    ; And then copy - although this technically runs one byte at a time, the CPU may optimise
    ; for larger blocks. A32 and O32 means we can use the 32-bi registers in 16-bit
    ; A32 = use 32-bit addressing
    ; O32 = use 32-bit operands
    a32 o32 rep movsb

    ; Restore ECX and DS register
    pop ecx
    pop ds

    ; Move ECX to point to the next sector and add 512 to the buffer
    ; so we move to the next 'sector' in RAM
    inc eax
    add ebx, 512

    ; And we go again for the next sector
    loop .loop

.done:
    ; Restore the registers and return
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
