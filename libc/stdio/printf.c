#include <limits.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

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

        if(*format == 'c')                                      /* is this format specifier for character*/
        {
            format++;
            char c = (char) va_arg(parameters, int);            /* read off the first variadic argument - char promotes to int */

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
        else if(*format == 's')                                 /* is this format specifier a string? */
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
        else
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
    }

    va_end(parameters);

    return written;
}