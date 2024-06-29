#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include <kernel/tty.h>

#include "vga.h"

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_colour;
uint16_t* terminal_buffer;

size_t strlen(const char* str)
{
    size_t len = 0;

    while(str[len])
    {
        len++;
    }

    return len;
}

void terminal_init(void)
{
    terminal_row = 0;
    terminal_column = 0;
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_GREY, VGA_COLOUR_BLACK);
    terminal_buffer = (uint16_t*) 0xB8000;

    for(size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for(size_t x = 0; x < VGA_WIDTH; x++)
        {
            const size_t index = y * VGA_WIDTH + x;
            terminal_buffer[index] = vga_entry(' ', terminal_colour);
        }
    }
}

void terminal_set_colour(uint8_t colour)
{
    terminal_colour = colour;
}

void terminal_putentry_at(char c, uint8_t colour, size_t x, size_t y)
{
    const size_t index = y * VGA_WIDTH + x;
    terminal_buffer[index] = vga_entry(c, colour);
}

void terminal_last_line_init()
{
    terminal_colour = vga_entry_colour(VGA_COLOUR_GREEN, VGA_COLOUR_BLACK);

    for(size_t x = 0; x < VGA_WIDTH; x++)
    {
        const size_t index = 25 * VGA_WIDTH + x;
        terminal_buffer[index] = vga_entry(' ', terminal_colour);
    }
}

void terminal_scroll()
{
    terminal_last_line_init();

    for(size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for(size_t x = 0; x < VGA_WIDTH; x++)
        {
            const size_t index = y * VGA_WIDTH + x;
            const size_t source = (y + 1) * VGA_WIDTH + x;
            terminal_buffer[index] = terminal_buffer[source];
        }
    }
    terminal_row = 24;
    
}

void terminal_put_char(char c)
{
    if(c == '\n')
    {
        if(++terminal_row == VGA_HEIGHT)
        {
            terminal_scroll();
        }

        terminal_column = 0;
    }
    else
    {
        terminal_putentry_at(c, terminal_colour, terminal_column, terminal_row);

        if(++terminal_column == VGA_WIDTH)
        {
            terminal_column = 0;

            if(++terminal_row == VGA_HEIGHT)
            {
                terminal_scroll();
            }
        }
    }

    
}

void terminal_write(const char* data, size_t size)
{
    for(size_t i = 0; i < size; i++)
    {
        terminal_put_char(data[i]);
    }
}

void terminal_write_string(const char* data)
{
    terminal_write(data, strlen(data));
}