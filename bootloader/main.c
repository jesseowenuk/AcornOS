asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>
#include <lib/real.h>
#include <lib/print.h>

void main(int boot_drive)
{
    init_vga_textmode();
    print("AcornOS Loader\n\n");
    print("=> Boot drive: %x\n", boot_drive);
    print("\n");

    for(;;)
    {
        struct real_mode_registers registers = {0};

        // Real mode interrupt 0x16
        real_mode_interrupt(0x16, &registers, &registers);

        char character = (char)(registers.eax & 0xff);
        text_write(&character, 1);
    }
}