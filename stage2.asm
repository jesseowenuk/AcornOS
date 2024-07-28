;
; kernel.asm
; Simple file which prints out a mesage - will be loaded by the boot sector code.
;    

org 0x5000

bits 16

    jmp main

    ;------------------------------------------------------------------
    ; Helpful includes
    ;------------------------------------------------------------------   
    %include "print_string.asm" 
    %include "load_gdt.asm"
    %include "a20.asm"

    ;------------------------------------------------------------------
    ; Stage 2 Main
    ;------------------------------------------------------------------  
main:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFF

    sti

    ;------------------------------------------------------------------
    ; Load the GDT
    ;------------------------------------------------------------------
    call load_gdt  

    ;------------------------------------------------------------------
    ; Load the kernel into memory
    ;------------------------------------------------------------------
    ;------------------------------------------------------------------
    ; Load the kernel file located in the second sector using 
    ; CHS addressing - Cylinder, Head Segment (note max we can address is
    ; the first 8 GB of a drive (1.44 MB on a floppy)) so...
    ; TODO: Implement LBA addressing
    ; Doing this ahead of the switch to protected mode as it's easier to do this
    ; with BIOS interrupts available
    ;------------------------------------------------------------------
    mov ah, 0x02                    ; interrupt 0x13, ah = 0x02 = read sectors into memory
    mov al, 12                       ; number of sectors to read (no more than 128!)
    mov ch, 0x00                    ; cylinder number (0 indexed) - 0
    mov cl, 0x03                    ; sector number (1 indexed so 3 is where we'll find our kernel)
    mov dh, 0x00                    ; head number (0 indexed) - 0
    mov dl, 0                       ; drive nunber (0 & 1 are floppy disks, 0x80 = drive 0, 0x81 = drive 1)
    mov bx, 0x1000                  ; we can't write directly to EX register so set BX to 0x1000 here
    mov es, bx                      ; then move this into the ES segment register (this is the segment in memory we are going to copy to)
    mov bx, 0                       ; now put the offset into the BX register - together this makes the pointer [ES:BX]
    int 0x13                        ; call interrupt 13 
    jc  kernel_read_error           ; uh oh we have a kernel read error - jump to the label to tell the user

    cmp al, 12                       ; if number of sectors read != number of sectors wanted to read then
    jc kernel_read_sector_error     ;    uh oh - we haven't read the number of sectors we wanted - tell the user

    jmp a20_jump                    ; everything went well - jump to enabling the A20 line

kernel_read_error:
    mov si, kernel_read_error_message ; load the error message into SI register
    call print_string               ; call print string
    jmp bootloader_end                 ; jump to bootloader end

kernel_read_sector_error:
    mov si, kernel_read_sector_error_message ; load the error message into SI register
    call print_string               ; call print string
    jmp bootloader_end              ; jump to bootloader end

    ;------------------------------------------------------------------
    ; Enable the A20 line via the keyboard controller
    ;------------------------------------------------------------------
a20_jump:
    call enable_a20

    ;------------------------------------------------------------------
    ; Enter protected mode
    ;------------------------------------------------------------------
    cli                             ; clear interrupts
    mov eax, cr0                    ; move the contents of the cr0 register into the EAX register
    or eax, 1                       ; set bit 0 by or'ing EAX register with 1
    mov cr0, eax                    ; move contents of EAX register back onto CR0 (this changes the protected mode bit to set - sending us head first into protected mode)
    
    jmp 0x08:protected_land          ; do a far jump to a code segment to clear the 16-bit garbage instructions

    ;------------------------------------------------------------------
    ; Bootloader End
    ;------------------------------------------------------------------
bootloader_end:
    cli                             ; disable interrupts
    hlt                             ; halt the system

    ;-----------------------------------------------------------------
    ; 32-bit land
    ;-----------------------------------------------------------------
bits 32

protected_land:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov eax, 0x10000
    add eax, 0x18
    mov ebx, [eax]
    call ebx

    cli
    hlt

    ;------------------------------------------------------------------
    ; Data
    ;------------------------------------------------------------------

kernel_read_error_message:
    db 'Kernel read error...', 13, 10, 0

kernel_read_sector_error_message:
    db 'Kernel sector load error...', 13, 10, 0


    ;-----------------------------------------------------------------
    ; Padding
    ;-----------------------------------------------------------------
    times 512 - ($-$$) db 0         ; pad out the file with 0's to 512

