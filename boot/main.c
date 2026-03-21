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
    write_string_to_screen("hello\n");
    write_string_to_screen("My name is Acorn\n");
    write_string_to_screen("Testing another length of string without specifying length :-)\b\b\b\b!");

    for(;;);
}