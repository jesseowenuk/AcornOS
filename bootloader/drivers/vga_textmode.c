#include <stdint.h>
#include <stddef.h>

#include <lib/io.h>

#include <drivers/vga_textmode.h>

#define VGA_BOTTOM ((VGA_ROWS * VGA_COLUMNS) - 1)
#define VGA_COLUMNS (80 * 2)
#define VGA_ROWS 25

static char *video_memory = (char *)0xb8000;
static size_t cursor_location = 0;
static int cursor_status = 0;
static uint8_t text_palette = 0x07;
static uint8_t cursor_palette = 0x70;

static void text_putchar(char character);

static void clear_cursor()
{
    video_memory[cursor_location + 1] = text_palette;
    return; 
}

static void draw_cursor()
{
    if(cursor_status)
    {
        video_memory[cursor_location + 1] = cursor_palette;
    }
}

static void text_clear()
{
    clear_cursor();

    for(size_t i = 0; i < VGA_BOTTOM; i += 2)
    {
        video_memory[i] = ' ';
        video_memory[i + 1] = text_palette;
    }

    cursor_location = 0;
    draw_cursor();
}

void init_vga_textmode(void)
{
    port_out_byte(0x3d4, 0x0a);
    port_out_byte(0x3d5, 0x20);

    text_clear();
    return;
}

void text_write(const char *buffer, size_t length)
{
    for(size_t i = 0; i < length; i++)
    {
        text_putchar(buffer[i]);
    }
}

static void text_putchar(char character)
{
    switch(character)
    {
        default:
        {
            clear_cursor();
            video_memory[cursor_location] = character;
            cursor_location += 2;
            draw_cursor();
            break;
        }
    }
}