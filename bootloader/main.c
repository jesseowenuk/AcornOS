asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>

void main(int boot_drive)
{
    init_vga_textmode();
    text_write("AcornOS Loader\n\n", 16);
    for(;;);
}