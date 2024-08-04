#include <stddef.h>
#include <stdint.h>

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

enum vga_colour {
    VGA_COLOUR_BLACK =          0,
    VGA_COLOUR_BLUE =           1,
    VGA_COLOUR_GREEN =          2,
    VGA_COLOUR_CYAN =           3,
    VGA_COLOUR_RED =            4,
    VGA_COLOUR_MAGENTA =        5,
    VGA_COLOUR_BROWN =          6,
    VGA_COLOUR_LIGHT_GREY =     7,
    VGA_COLOUR_DARK_GREY =      8,
    VGA_COLOUR_LIGHT_BLUE =     9,
    VGA_COLOUR_LIGHT_GREEN =    10,
    VGA_COLOUR_LIGHT_CYAN =     11,
    VGA_COLOUR_LIGHT_RED =      12, 
    VGA_COLOUR_LIGHT_MAGENTA =  13,
    VGA_COLOUR_LIGHT_BROWN =    14,
    VGA_COLOUR_WHITE =          15
};

uint16_t* vga_buffer;

uint8_t vga_colour_palette(enum vga_colour foreground_colour, enum vga_colour background_colour)
{
    return foreground_colour | background_colour << 4;
}

void kernel_entry(void)
{  
    vga_buffer = (uint16_t*)0xB8000;

    uint8_t attribute = vga_colour_palette(VGA_COLOUR_WHITE, VGA_COLOUR_LIGHT_BLUE);
    uint16_t c = 'H' | attribute << 8;

    vga_buffer[0] = c;
   
    for(;;);
}