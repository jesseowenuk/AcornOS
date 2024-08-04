#include <stddef.h>
#include <stdint.h>

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

uint16_t* vga_buffer;

void kernel_entry(void)
{  
    vga_buffer = (uint16_t*)0xB8000;

    uint8_t attribute = 15 | 9 << 4;
    uint16_t c = 'H' | attribute << 8;

    vga_buffer[0] = c;
   
    for(;;);
}