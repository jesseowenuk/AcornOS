#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RESERVED_BLOCK      0xfffffffffffffff0

static int verbose = 0;

static FILE* image;
static uint64_t image_size;
static uint64_t blocks;
static uint64_t bytes_per_block;

static inline void write_qword(uint64_t location, uint64_t the_qword)
{
    // put the file pointer in the right place according to the location
    // provided
    fseek(image, (long)location, SEEK_SET);

    // write the qword provided into this location in the file
    fwrite(&the_qword, 8, 1, image);

    return;
}

static void format_pass1(int argc, char **argv)
{
    if(argc <= 3)
    {
        fprintf(stderr, "%s: error: unspecified block size.\n", argv[0]);
        fclose(image);
        abort();
    }

    if(verbose)
    {
        fprintf(stdout, "formatting...\n");
    }

    // convert string into integer
    bytes_per_block = atoi(argv[3]);

    // check if block size is a multiple of 512
    if((bytes_per_block <= 0) || (bytes_per_block % 512))
    {
        fprintf(stderr, "%s: error: block size MUST be a multiple of 512.\n", argv[0]);
        fclose(image);
        abort();
    }

    // check if the image is block-aligned
    if(image_size & bytes_per_block)
    {
        fprintf(stderr, "%s: error: image is not block-aligned.\n", argv[0]);
        fclose(image);
        abort();
    }

    // calculate the number of blocks needed
    blocks = image_size / bytes_per_block;

    // write signature
    fseek(image, 4, SEEK_SET);
    fputs("_ECH_FS_", image);
    
    // total blocks
    write_qword(12, blocks);

    // directory size
    // blocks / 20 (roughly 5% of the total)
    write_qword(20, blocks / 20);

    // block size
    write_qword(28, bytes_per_block);

    fseek(image, (RESERVED_BLOCK * bytes_per_block), SEEK_SET);

    if(verbose)
    {
        fprintf(stdout, "zeroing");
    }
    
    return;
}

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

    if((argc > 2) && (!strcmp(argv[2], "format")))
    {
        format_pass1(argc, argv);
    }

    return EXIT_SUCCESS;
}