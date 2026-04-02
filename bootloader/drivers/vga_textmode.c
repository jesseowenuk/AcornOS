#include <lib/io.h>

#include <drivers/vga_textmode.h>

void init_vga_textmode(void)
{
    port_out_byte(0x3d4, 0x0a);
    port_out_byte(0x3d5, 0x20);

    return;
}