#include <lib/io.h>

#include <drivers/vga_text_mode.h>

#define VIDEO_BOTTOM ((VGA_ROWS * VGA_COLUMNS) - 1)
#define VGA_ROWS (80 * 2)
#define VGA_COLUMNS 25

static char *video_memory = (char *)0xb8000;
static size_t cursor_location = 0;
static int cursor_status = 1;
static uint8_t text_colour = 0x07;
static uint8_t cursor_colour = 0x70;

static void clear_cursor(void)
{
    video_memory[cursor_location + 1] = text_colour;
    return;
}

static void draw_cursor(void)
{
    if(cursor_status)
    {
        video_memory[cursor_location + 1] = cursor_colour;
    }
    return;
}

static void clear_screen(void)
{
    clear_cursor();

    for(size_t i = 0; i < VIDEO_BOTTOM; i += 2)
    {
        video_memory[i] = ' ';
        video_memory[i + 1] = text_colour;
    }

    cursor_location = 0;
    draw_cursor();

    return;
}


void init_vga_text_mode(void)
{
    // Hide the cursor
    ouput_byte_via_port(0x0a, 0x3d4);       // Select cursor start register
    ouput_byte_via_port(0x20, 0x3d5);       // hide the cursor to stop it blinking
    clear_screen();                         // clear the screen
    return;
}