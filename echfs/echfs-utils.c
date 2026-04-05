#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#define BYTES_PER_SECTOR        512
#define SECTORS_PER_BLOCK       (bytes_per_block / BYTES_PER_SECTOR) 
#define BYTES_PER_BLOCK         (SECTORS_PER_BLOCK * BYTES_PER_SECTOR)
#define RESERVED_BLOCKS         16

static int verbose = 0;

static FILE* image;
static uint64_t image_size;
static uint64_t blocks;
static uint64_t bytes_per_block;

static inline uint64_t read_qword(uint64_t location)
{
    uint64_t the_qword = 0;

    // put the file pointer at the right location
    fseek(image, (long)location, SEEK_SET);

    // read the qword from this location in the file
    fread(&the_qword, 8, 1, image);

    return the_qword;
}

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

    fseek(image, (RESERVED_BLOCKS * bytes_per_block), SEEK_SET);

    if(verbose)
    {
        fprintf(stdout, "zeroing");
    }

    // Zero out the rest of the image
    uint8_t *zero_block = calloc(bytes_per_block, 1);
    if(!zero_block)
    {
        perror("calloc failure");
        abort();
    }

    for(uint64_t i = (RESERVED_BLOCKS * bytes_per_block); i < image_size; i += bytes_per_block)
    {
        fwrite(zero_block, bytes_per_block, 1, image);
        if(verbose)
        {
            fputc('.', stdout);
        }
    }

    free(zero_block);

    if(verbose)
    {
        fputc('\n', stdout);
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

    // If "format" argument provided do the first pass of formatting
    // (writing the signature, the directory blocks and zeroing the rest)
    if((argc > 2) && (!strcmp(argv[2], "format")))
    {
        format_pass1(argc, argv);
    }

    // Check the provided file is a valid ECHS formatted file
    char signature[8] = {0};
    fseek(image, 4, SEEK_SET);
    fread(signature, 8, 1, image);
    if(strncmp(signature, "_ECH_FS_", 8))
    {
        fprintf(stderr, "%s: error: echidnaFS signature missing.\n", argv[0]);
        fclose(image);
        return EXIT_FAILURE;
    }

    if(verbose)
    {
        fprintf(stdout, "echidnaFS signature found.\n");
    }

    if(verbose)
    {
        fprintf(stdout, "image size: %" PRIu64 " bytes\n", image_size);
    }

    // read the bytes per block from the directory structure
    bytes_per_block = read_qword(28);

    if(verbose)
    {
        fprintf(stdout, "bytes per block: %" PRIu64 "\n", BYTES_PER_BLOCK);
    }

    if(image_size % bytes_per_block)
    {
        fprintf(stderr, "%s: error: image is not block-aligned.\n", argv[0]);
        fclose(image);
        return EXIT_FAILURE;
    }

    blocks = image_size / bytes_per_block;

    if(verbose)
    {
        fprintf(stdout, "block count: %" PRIu64 "\n", blocks);
    }

    return EXIT_SUCCESS;
}