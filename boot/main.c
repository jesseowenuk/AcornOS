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
    write_string_to_screen("hello!\nboo\nboo\nboo\nboo\n\n\n\n\nboo\n\n\nHELLO WEMBLEY!!!\n\n\n", 52);
    write_string_to_screen("hello!\nboo\nboo\nboo\nboo\n\n\n\n\nboo\n\n\nHELLO WEMBLEY!!!\n\n\n", 52);
    write_string_to_screen("here's another one\n", 19);
    for(;;);
}