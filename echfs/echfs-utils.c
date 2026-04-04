#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int verbose = 0;

static FILE* image;
static uint64_t image_size;

int main(int argc, char **argv)
{
    // Check if the verbose flag has been passed in 
    if((argc > 1) && (!strcmp(argv[1], "-v")))
    {
        // if it has turn on verbose output by flipping the flag
        verbose = 1;

        // consume the -v flag with the program name so it doesn't get handled again
        argv[1] = argv[0];

        // advance on to the next argument
        argv++;

        // decrease the number of arguments left to handle
        argc--;
    }

    // If there is only 1 argument left, we don't have enough info
    // to proceed - tell the user how to use this utility and exit.
    if(argc == 1)
    {
        fprintf(stderr, "Usage: %s (-v) [image] <action> <args...>\n", argv[0]);
        return EXIT_SUCCESS;
    }

    // Try and open the file to be added
    if((image = fopen(argv[1], "r+")) == NULL)
    {
        fprintf(stderr, "%s: error: couldn't access `%s`.\n", argv[0], argv[1]);
        return EXIT_FAILURE;
    }

    // Calculate the size of the file provided.
    // Move the file pointer to the end of the file
    fseek(image, 0L, SEEK_END);

    // Use ftell to read the current position in the file
    image_size = (uint64_t)ftell(image);

    // rewind the file pointer back to the start of the file
    rewind(image);

    return EXIT_SUCCESS;
}