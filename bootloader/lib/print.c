#include <stdint.h>
#include <stddef.h>
#include <stdarg.h>

#include <lib/print.h>
#include <drivers/vga_textmode.h>

static const char *base_digits = "0123456789abcdef";

#define PRINT_BUFFER_MAX 512

// Adds a string to the buffer ready to print
static void add_string(char *print_buffer, size_t *print_buffer_i, const char *string)
{
    size_t i;

    for(i = 0; string[i]; i++)
    {
        if(*print_buffer_i == (PRINT_BUFFER_MAX - 1))
        {
            break;
        }

        print_buffer[(*print_buffer_i)++] = string[i];
    }

    print_buffer[*print_buffer_i] = 0;
}

// Adds a character to the buffer ready to print
static void add_character(char *print_buffer, size_t *print_buffer_i, char character)
{
    if(*print_buffer_i < (PRINT_BUFFER_MAX - 1))
    {
        print_buffer[(*print_buffer_i)++] = character;
    }

    print_buffer[*print_buffer_i] = 0;
}

// Adds a hex number to the buffer ready to print
static void add_hex(char *print_buffer, size_t *print_buffer_i, uint32_t hex_number)
{
    int i;
    char buffer[9] = {0};

    if(!hex_number)
    {
        add_string(print_buffer, print_buffer_i, "0x0");
        return;
    }

    for(i = 7; hex_number; i--)
    {
        buffer[i] = base_digits[(hex_number % 16)];
        hex_number = hex_number / 16;
    }
    
    add_string(print_buffer, print_buffer_i, "0x");
    add_string(print_buffer, print_buffer_i, buffer + i + 1);

    return;
}

void print(const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);

    char print_buffer[PRINT_BUFFER_MAX];
    size_t print_buffer_i = 0;

    while(*format != '\0')
    {
        // loop through non format specifying characters
        while(*format && *format != '%')
        {
            add_character(print_buffer, &print_buffer_i, *format);
            format++;
        }

        if(*format == '%')
        {
            format++;

            if(*format != '\0')
            {

                switch(*format)
                {
                    case 'x':
                    {
                        add_hex(print_buffer, &print_buffer_i, va_arg(arguments, uint32_t));
                        break;
                    }

                    default:
                    {
                        add_character(print_buffer, &print_buffer_i, '?');
                    }
                }

                format++;
            }
            else
            {
                // handle the trailing '%'
                add_character(print_buffer, &print_buffer_i, '%');
            }
        }
    }

    va_end(arguments);
    text_write(print_buffer, print_buffer_i);
}