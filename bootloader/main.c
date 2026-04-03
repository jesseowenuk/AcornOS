asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>
#include <lib/real.h>
#include <lib/print.h>

extern uint8_t bss_begin;
extern uint8_t bss_end;

void main(int boot_drive)
{
    // Zero out the .bss section
    for(uint8_t *p = &bss_begin; p < &bss_end; p++)
    {
        *p = 0;
    }

    init_vga_textmode();
    print("AcornOS Loader\n\n");
    print("=> Boot drive: %x\n\n", boot_drive);

    for(;;)
    {
        struct real_mode_registers registers = {0};

        // Real mode interrupt 0x16
        real_mode_interrupt(0x16, &registers, &registers);

        char character = (char)(registers.eax & 0xff);
        text_write(&character, 1);
    }
}