#include <lib/io.h>

#include <drivers/vga_text_mode.h>

void init_vga_text_mode(void)
{
    // Hide the cursor
    ouput_byte_via_port(0x0a, 0x3d4);       // Select cursor start register
    ouput_byte_via_port(0x20, 0x3d5);       // hide the cursor to stop it blinking
    return;
}