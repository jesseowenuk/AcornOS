#include <stddef.h>
#include <stdint.h>

#include <lib/libc.h>

uint64_t __umoddi3(uint64_t a, uint64_t b)
{
    uint64_t remainder = a;

    while(remainder >= b)
    {
        remainder -= b;
    }

    return remainder;
}

void *memcpy(void *destination, const void *source, size_t string_length)
{
    size_t i = 0;

    uint8_t *destination_temp = destination;
    const uint8_t *source_temp = source;

    for(i = 0; i < string_length; i++)
    {
        destination_temp[i] = source_temp[i];
    }

    return destination;
}

int strcmp(const char *string_one, const char *string_two)
{
    size_t i;

    for(i = 0; string_one[i] == string_two[i]; i++)
    {
        if((!string_one[i]) && (!string_two[i]))
        {
            return 0;
        }
    }

    return 1;
}

int strncmp(const char *string_one, const char *string_two, size_t string_length)
{
    size_t i;

    for(i = 0; i < string_length; i++)
    {
        if(string_one[i] != string_two[i])
        {
            return 1;
        }
    }

    return 0;
}