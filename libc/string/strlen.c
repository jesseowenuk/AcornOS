#include <string.h>

/* Calculates the length of a string
   by looping throught the character array and incrementing len each
   time through. */
size_t strlen(const char* str)
{
    size_t len = 0;

    while(str[len])
    {
        len++;
    }

    return len;
}