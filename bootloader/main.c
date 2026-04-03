asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>
#include <lib/real.h>

void main(int boot_drive)
{
    init_vga_textmode();
    text_write("AcornOS Loader\n\n", 16);
    for(;;)
    {
        struct real_mode_registers registers = {0};

        // Real mode interrupt 0x16
        real_mode_interrupt(0x16, &registers, &registers);

        char character = (char)(registers.eax & 0xff);
        text_write(&character, 1);
    }
}