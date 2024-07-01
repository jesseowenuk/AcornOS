#include <limits.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#define ASCII_OFFSET 48

/* Define the decimal numbers */
#define DIGIT_0 48
#define DIGIT_1 49
#define DIGIT_2 50
#define DIGIT_3 51
#define DIGIT_4 52
#define DIGIT_5 53
#define DIGIT_6 54
#define DIGIT_7 55
#define DIGIT_8 56
#define DIGIT_9 57

/* Expand above to Hex */
#define HEX_10 65
#define HEX_11 66
#define HEX_12 67
#define HEX_13 68
#define HEX_14 69
#define HEX_15 70


static bool print(const char* data, size_t length)
{
    const unsigned char* bytes = (const unsigned char*) data;

    for(size_t i = 0; i < length; i++)
    {
        if(putchar(bytes[i]) == EOF)
        {
            return false;
        }
    }

    return true;
}

char intToString(int integer)
{
    char c;
    if(integer < 10)
    {
        c = integer + ASCII_OFFSET;
    }
    else
    {
        // TODO: Implement numbers 10+
        c = ASCII_OFFSET;
    }
    
    return c;
}

int printf(const char* restrict format, ...)
{
    va_list parameters;
    va_start(parameters, format);

    int written = 0;

    /* loop through the format specifier 
     * e.g. "Hello my name is %s" */
    while(*format != '\0')
    {
        size_t max_remaining = INT_MAX - written;

        /* Is the first or second character in the format specifier %? */
        if(format[0] != '%' || format[1] == '%')
        {
            /* If it's the first one increment format */
            if(format[0] == '%')
            {
                format++;
            }

            /* Extract free text from the format string
               Stop when you find a '%' character next */
            size_t amount = 1;

            while(format[amount] && format[amount] != '%')
            {
                amount++;
            }

            if(max_remaining < amount)
            {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }

            if(!print(format, amount))
            {
                return -1;
            }

            format += amount;
            written += amount;
            continue;
        }

        const char* format_begun_at = format++;

        switch(*format)
        {
            case 'd':
            {
                format++;
                int i = va_arg(parameters, int); 
                //size_t len = strlen(decimal);

                if(!max_remaining)
                {
                    // TODO: Set errno to EOVERFLOW
                    return -1;
                }

                char str = intToString(i);

                if(!print(&str, sizeof(str)))
                {
                    return -1;
                }

                written++;
            }
            break;

            case 'c': 
            {
                format++;
                char c = (char) va_arg(parameters, int);  /* read off the first variadic argument - char promotes to int */
            
                if(!max_remaining)
                {
                    // TODO: Set errno to EOVERFLOW.
                    return -1;
                }

                if(!print(&c, sizeof(c)))
                {
                    return -1;
                }

                written++;
            
            }
            break;

            case 's':
            {
                format++;
                const char* str = va_arg(parameters, const char*);  /* read off the next variadic argument */
                size_t len = strlen(str);

                if(max_remaining < len)
                {
                    // TODO: Set errno to EOVERFLOW.
                    return -1;
                }

                if(!print(str, len))
                {
                    return -1;
                }

                written += len;
            }
            break;

            case 'x':
            {
                format = format_begun_at;
                size_t length = strlen(format);


            }
            break;

            default:
            {
                format = format_begun_at;
                size_t len = strlen(format);

                if(max_remaining < len)
                {
                    // TODO: Set errno to EOVERFLOW.
                    return -1;
                }

                if(!print(format, len))
                {
                    return -1;
                }

                written += len;
                format += len;
            }
            break;
        }
    }

    va_end(parameters);

    return written;
}