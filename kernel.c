#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Check if the compiler thinks you are targetting the wrong operarting system. */
#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

/* This tutorial will only work for the 32-bit ix86 targets. */
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

/* Hardware text mode colour constants */
enum vga_colour 
{
    VGA_COLOUR_BLACK = 0,
    VGA_COLOUR_BLUE = 1,
    VGA_COLOUR_GREEN = 2,
    VGA_COLOUR_CYAN = 3,
    VGA_COLOUR_RED = 4,
    VGA_COLOUR_MAGENTA = 5,
    VGA_COLOUR_BROWN = 6,
    VGA_COLOUR_LIGHT_GREY = 7,
    VGA_COLOUR_DARK_GREY = 8,
    VGA_COLOUR_LIGHT_BLUE = 9,
    VGA_COLOUR_LIGHT_GREEN = 10,
    VGA_COLOUR_LIGHT_CYAN = 11,
    VGA_COLOUR_LIGHT_RED = 12,
    VGA_COLOUR_LIGHT_MAGENTA = 13,
    VGA_COLOUR_LIGHT_BROWN = 14,
    VGA_COLOUR_WHITE = 15,
};

static inline uint8_t vga_entry_colour(enum vga_colour fg, enum vga_colour bg)
{
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t colour)
{
    return (uint16_t) uc | (uint16_t) colour << 8;
}

size_t strlen(const char* str)
{
    size_t len = 0;

    while(str[len])
    {
        len++;
    }

    return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_colour;
uint16_t* terminal_buffer;

void terminal_init(void)
{
    terminal_row = 0;
    terminal_column = 0;
    terminal_colour = vga_entry_colour(VGA_COLOUR_GREEN, VGA_COLOUR_BLACK);
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

void print_007()
{
    terminal_write_string("     0000             0000        7777777777777777/========___________\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_BLUE, VGA_COLOUR_BLACK);
    terminal_write_string("   00000000         00000000      7777^^^^^^^7777/ || ||   ___________\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_RED, VGA_COLOUR_BLACK);
    terminal_write_string("  000    000       000    000     777       7777/=========//\n");
    terminal_write_string("000      000     000      000             7777// ((     //\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_CYAN, VGA_COLOUR_BLACK);
    terminal_write_string("0000      0000   0000      0000           7777//   \\   //\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_MAGENTA, VGA_COLOUR_BLACK);
    terminal_write_string("0000      0000   0000      0000          7777//========//\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_GREY, VGA_COLOUR_BLACK);
    terminal_write_string("0000      0000   0000      0000         7777\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_RED, VGA_COLOUR_BLACK);
    terminal_write_string("0000      0000   0000      0000        7777\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_BROWN, VGA_COLOUR_BLACK);
    terminal_write_string(" 000      000     000      000        7777\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_GREEN, VGA_COLOUR_BLACK);
    terminal_write_string("  000    000       000    000       77777\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_CYAN, VGA_COLOUR_BLACK);
    terminal_write_string("   00000000         00000000       7777777\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_WHITE, VGA_COLOUR_BLACK);
    terminal_write_string("     0000             0000        777777777\n\n\n");
    terminal_colour = vga_entry_colour(VGA_COLOUR_LIGHT_GREEN, VGA_COLOUR_BLACK);
    terminal_write_string("Unknown\n");
}

void kernel_main(void)
{
    /* Initialise terminal interface */
    terminal_init();

    print_007();

    /*terminal_write_string("1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\n23\n24\n25\n26\n27\n28\n29\n30\n\n\n\n");*/

    /*for(int i = 0; i < 35; i++)
    {
        terminal_write_string("I am random text, I promise. whahahahahahahaha. 123");
    }

    terminal_write_string("\n\n\n\n\n");*/

    /*terminal_write_string("\n\n\nHello little Acorn! :)\n\n");*/
}