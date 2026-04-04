#include <stddef.h>
#include <stdint.h>

#include <lib/libc.h>

void *memcpy(void *destination, const void *source, size_t count)
{
    size_t i = 0;

    uint8_t *destination_temp = destination;
    const uint8_t *source_temp = source;

    for(i = 0; i < count; i++)
    {
        destination_temp[i] = source_temp[i];
    }

    return destination;
}