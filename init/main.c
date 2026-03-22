asm(
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_text_mode.h>
#include <lib/real_mode.h>

void main(int boot_drive)
{
    // TODO
    init_vga_text_mode();
    write_string_to_screen("AcornOS\n");
    write_string_to_screen("*******\n\n");

    for(;;)
    {
        struct real_mode_registers registers = {0};
        // Call real mode int 0x16 to get character input from the user 
        // and print it out
        real_mode_interrupt(0x16, &registers, &registers);
        char character = (char)(registers.eax & 0xff);
        write_string_to_screen(&character);
    }
}