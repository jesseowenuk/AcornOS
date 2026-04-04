#include <stddef.h>
#include <stdint.h>

#include <lib/libc.h>

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
}