#include <lib/io.h>

#include <drivers/vga_text_mode.h>

#define VGA_BOTTOM ((VGA_ROWS * VGA_COLUMNS) - 1)
#define VGA_COLUMNS (80 * 2)
#define VGA_ROWS 25

static char *video_memory = (char *)0xb8000;
static size_t cursor_location = 0;

static uint8_t text_palette = 0x07;


static int cursor_status = 1;
static uint8_t cursor_palette = 0x70;

static void write_character_to_screen(char character);

static void clear_cursor(void)
{
    video_memory[cursor_location + 1] = text_palette;
    return;
}

static void draw_cursor(void)
{
    if(cursor_status)
    {
        video_memory[cursor_location + 1] = cursor_palette;
    }
    return;
}

static void clear_screen(void)
{
    clear_cursor();

    for(size_t i = 0; i < VGA_BOTTOM; i += 2)
    {
        video_memory[i] = ' ';
        video_memory[i + 1] = text_palette;
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

static void scroll_down()
{
    // Move the text up by one line
    for(size_t i = 0; i <= VGA_BOTTOM - VGA_COLUMNS; i++)
    {
        video_memory[i] = video_memory[i + VGA_COLUMNS];
    }

    // Now clear the last line
    for(size_t i = VGA_BOTTOM; i > VGA_BOTTOM - VGA_COLUMNS; i -= 2)
    {
        video_memory[i] = text_palette;
        video_memory[i - 1] = ' ';
    }

    return;
}

static int get_cursor_position_y(void)
{
    return cursor_location / VGA_COLUMNS;
}

static void set_cursor_position(int x, int y)
{
    clear_cursor();
    cursor_location = y * VGA_COLUMNS + x * 2;
    draw_cursor();
    return;
}

static void write_character_to_screen(char character)
{
    switch(character)
    {
        case 0x00:
            break;

        case 0x0A:
        {
            if(get_cursor_position_y() == (VGA_ROWS - 1))
            {
                clear_cursor();
                scroll_down();
                set_cursor_position(0, (VGA_ROWS -1));
            }
            else
            {
                set_cursor_position(0, (get_cursor_position_y() + 1));
            }

            break;
        }

        default:
        {
            clear_cursor();
            video_memory[cursor_location] = character;

            if(cursor_location >= (VGA_BOTTOM - 1))
            {
                scroll_down();
                cursor_location = VGA_BOTTOM - (VGA_COLUMNS- 1);
            }
            else
            {
                cursor_location += 2;
            }

            draw_cursor();
        }
    }
}

size_t calculate_string_length(const char *string_buffer)
{
    size_t string_length = 0;
    while(string_buffer[string_length] != 0x00)
    {
        string_length++;
    }

    return string_length;
}

void write_string_to_screen(const char *string_buffer)
{
    size_t position = 0;
    while(string_buffer[position] != 0x00)
    {
        write_character_to_screen(string_buffer[position]);
        position++;
    }
}