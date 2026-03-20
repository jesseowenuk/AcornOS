asm(
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_text_mode.h>

void main(int boot_drive)
{
    // TODO
    init_vga_text_mode();
    write_string_to_screen("hello world!", 12);
    for(;;);
}