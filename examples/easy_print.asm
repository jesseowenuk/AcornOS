;
; A boot sector program to print hello world to the screen using a BIOS routine
;

mov ah, 0x0E                                ; Move into teletype mode

mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10

mov al, ' '
int 0x10

mov al, 'W'
int 0x10
mov al, 'o'
int 0x10
mov al, 'r'
int 0x10
mov al, 'l'
int 0x10
mov al, 'd'
int 0x10
mov al, '!'
int 0x10

mov al, 0x0A                                ; Line feed
int 0x10
mov al, 0x0D                                ; Carriage return
int 0x10

jmp $                                       ; Halt the system by jumping to this address indefinitley

times 510 - ($ - $$) db 0                   ; Pad the file with 0's
dw 0xAA55                                   ; The magic number