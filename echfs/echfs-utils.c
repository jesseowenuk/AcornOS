#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int verbose = 0;

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

    if(argc == 1)
    {
        fprintf(stderr, "Usage: %s (-v) [image] <action> <args...>\n", argv[0]);
    }

    return EXIT_SUCCESS;
}