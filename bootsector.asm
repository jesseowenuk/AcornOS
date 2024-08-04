;
; bootsector.asm
; Prints a single character to the screen
;
    ;------------------------------------------------------------------
    ; Bootsector is loaded at 0x7C00
    ;------------------------------------------------------------------
    org 0x7C00

    ;------------------------------------------------------------------
    ; Print a Hello Message :)
    ;------------------------------------------------------------------
    mov si, hello_message
    call print_string

    ;------------------------------------------------------------------
    ; Load the stage 2 file located in the second sector using 
    ; CHS addressing - Cylinder, Head Segment (note max we can address is
    ; the first 8 GB of a drive (1.44 MB on a floppy)) so...
    ; TODO: Implement LBA addressing
    ;------------------------------------------------------------------
    mov ah, 0x02                    ; interrupt 0x13, ah = 0x02 = read sectors into memory
    mov al, 1                       ; number of sectors to read (no more than 128!)
    mov ch, 0x00                    ; cylinder number (0 indexed) - 0
    mov cl, 0x02                    ; sector number (1 indexed so 2 is where we'll find our kernel)
    mov dh, 0x00                    ; head number (0 indexed) - 0
    mov dl, 0x80                    ; drive nunber (0 & 1 are floppy disks, 0x80 = drive 0, 0x81 = drive 1)
    mov bx, 0x500                   ; we can't write directly to EX register so set BX to 0x0500 here
    mov es, bx                      ; then move this into the ES segment register (this is the segment in memory we are going to copy to)
    mov bx, 0                       ; now put the offset into the BX register - together this makes the pointer [ES:BX]
    int 0x13                        ; call interrupt 13 
    jc  disk_read_error             ; uh oh we have a disk read error - jump to the label to tell the user

    cmp al, 1                       ; if number of sectors read != number of sectors wanted to read then
    jc disk_read_sector_error       ;    uh oh - we haven't read the number of sectors we wanted - tell the user

    jmp 0x500:0                       ; if we got here everyhting went well - jump to the place in memory where we loaded our kernel

disk_read_error:
    mov si, disk_read_error_message ; load the error message into SI register
    call print_string               ; call print string
    jmp system_end                  ; jump to system end

disk_read_sector_error:
    mov si, disk_read_sector_error_message ; load the error message into SI register
    call print_string               ; call print string
    jmp system_end                  ; jump to system end

    ;------------------------------------------------------------------
    ; Systems End - hopefully we never get here!
    ;------------------------------------------------------------------
system_end:
    cli                             ; disable interrupts
    hlt                             ; halt the system

    ;------------------------------------------------------------------
    ; Helpful includes
    ;------------------------------------------------------------------
    %include "print_string.asm" 

    ;------------------------------------------------------------------
    ; Data
    ;------------------------------------------------------------------
hello_message:
    db 'Hello Acorn! :)', 13, 10, 0

disk_read_error_message:
    db 'Disk read error...', 13, 10, 0

disk_read_sector_error_message:
    db 'Sector load error...', 13, 10, 0

    ;-----------------------------------------------------------------
    ; Magic Number and padding
    ;-----------------------------------------------------------------
    times 510 - ($-$$) db 0         ; pad out the file with 0's to 510
    dw 0xAA55                       ; the magic number!!!
