asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>

void main(int boot_drive)
{
    char* memory = (char*)0xb8000;

    memory[0] = 'A';
    memory[1] = 0x0F;

    init_vga_textmode();
    for(;;);
}