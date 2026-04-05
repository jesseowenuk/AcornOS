#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#define SEARCH_FAILURE          0xffffffffffffffff
#define ROOT_ID                 0xffffffffffffffff
#define BYTES_PER_SECTOR        512
#define SECTORS_PER_BLOCK       (bytes_per_block / BYTES_PER_SECTOR) 
#define BYTES_PER_BLOCK         (SECTORS_PER_BLOCK * BYTES_PER_SECTOR)
#define ENTRIES_PER_SECTOR      2
#define ENTRIES_PER_BLOCK       (SECTORS_PER_BLOCK * ENTRIES_PER_SECTOR)
#define FILENAME_LENGTH         218
#define RESERVED_BLOCKS         16
#define FILE_TYPE               0
#define DIRECTORY_TYPE          1
#define DELETED_ENTRY           0xfffffffffffffffe

static int verbose = 0;

static FILE* image;
static uint64_t image_size;
static uint64_t blocks;
static uint64_t fat_size;
static uint64_t fat_start = RESERVED_BLOCKS;
static uint64_t directory_size;
static uint64_t directory_start;
static uint64_t data_start;
static uint64_t bytes_per_block;

typedef struct
{
    uint64_t parent_id;
    uint8_t type;
    char filename[FILENAME_LENGTH]; 
    uint8_t permissions;
    uint16_t owner;
    uint16_t group;
    uint64_t time;
    uint64_t payload;
    uint64_t size;
} __attribute__((packed)) entry_type;

typedef struct
{
    uint64_t target_entry;
    entry_type target;
    entry_type parent;
    char name[FILENAME_LENGTH];
    int failure;
    int not_found;
} path_result_type;

static inline uint16_t read_word(uint64_t location)
{
    uint16_t the_word = 0;
    fseek(image, (long)location, SEEK_SET);
    fread(&the_word, 2, 1, image);
    return the_word;
}

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

static inline void read_entry(entry_type *result, uint64_t entry)
{
    uint64_t location = (directory_start * bytes_per_block) + (entry * sizeof(entry_type));

    if(location >= (directory_start + directory_size) * bytes_per_block)
    {
        fprintf(stderr, "PANIC! ATTEMPTING TO READ DIRECTORY OUT OF BOUNDS!\n");
        abort();
    }

    fseek(image, (long)location, SEEK_SET);
    fread(result, sizeof(entry_type), 1, image);
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

static uint64_t search(const char *name, uint64_t parent, uint8_t type)
{
    // returns unique entry number, SEARCH_FAILURE upon failure / not found
    uint64_t location = (directory_start * bytes_per_block);
    fseek(image, (long)location, SEEK_SET);
    for(uint64_t i = 0; ; i++)
    {
        entry_type entry;

        fread(&entry, sizeof(entry_type), 1, image);

        // Check if past last entry
        if(!entry.parent_id)
        {
            return SEARCH_FAILURE;
        }

        // Check if past directory table
        if(i >= (directory_size * ENTRIES_PER_BLOCK))
        {
            return SEARCH_FAILURE;
        }

        if((entry.parent_id == parent) && (entry.type == type) && (!strcmp(entry.filename, name)))
        {
            return i;
        }
    }
}

static path_result_type path_resolver(const char *path, uint8_t type)
{
    // returns a sruct of useful information
    // failure flag set upon failure
    // not_found flag set on not found
    // even if the file is not found, info about the "parent"
    // directory and name are still returned.
    char name[FILENAME_LENGTH];
    entry_type parent = {0};
    int last = 0;
    int i;
    path_result_type result;
    entry_type empty_entry = {0};

    // Construct the inital result structure
    result.name[0] = 0;
    result.target_entry = 0;
    result.parent = empty_entry;
    result.target = empty_entry;
    result.failure = 0;
    result.not_found = 0;

    parent.payload = ROOT_ID;

    if((type == DIRECTORY_TYPE) && !strcmp(path, "/"))
    {
        result.target.payload = ROOT_ID;
        return result;  // exception for root
    }

    if((type == FILE_TYPE) && !strcmp(path, "/"))
    {
        result.failure = 1;
        return result;  // fail if looking for a file named "/"
    }

    if(*path == '/')
    {
        path++;
    }

    int done = 0;

    while(!done)
    {
        i = 0;
        last = 0;

        while(*path != '/')
        {
            if(!*path)
            {
                last = 1;
                break;
            }

            name[i++] = *path;
            path++;
        }

        name[i] = 0;

        if(!last)
        {
            uint64_t search_result = search(name, parent.payload, DIRECTORY_TYPE);
            if(search_result == SEARCH_FAILURE)
            {
                result.failure = 1;
                return result;
            }

            read_entry(&parent, search_result);
        }
        else
        {
            uint64_t search_result = search(name, parent.payload, type);
            if(search_result == SEARCH_FAILURE)
            {
                result.not_found = 1;
            }
            else
            {
                read_entry(&result.target, search_result);
                result.target_entry = search_result;
            }

            result.parent = parent;
            strcpy(result.name, name);
            done = 1;
        }
    }

    return result;

}

static void mkdir_command(int argc, char **argv)
{
    uint64_t i;
    entry_type entry = {0};

    if(argc < 4)
    {
        fprintf(stderr, "%s: %s: missing argument: directory name.\n", argv[0], argv[2]);
        return;
    }

    path_result_type path_result = path_resolver(argv[3], DIRECTORY_TYPE);

    // find empty entry
    uint64_t location = (directory_start * bytes_per_block);
    fseek(image, (long)location, SEEK_SET);
    for(i = 0; ; i++)
    {
        entry_type entry_i;
        fread(&entry_i, sizeof(entry_type), 1, image);
        if((entry_i.parent_id == 0) || (entry_i.parent_id == DELETED_ENTRY))
        {
            break;
        }
    }

    entry.parent_id = path_result.parent.payload;

    if(verbose)
    {
        fprintf(stdout, "new directory's parent ID: %" PRIu64 "\n", entry.parent_id);
    }
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

    if(verbose)
    {
        fprintf(stdout, "declared block count: %" PRIu64 "\n", read_qword(12));
    }

    if(read_qword(12) != blocks)
    {
        fprintf(stderr, "%s: warning: declared block count mismatch.\n", argv[0]);
    }

    fat_size = (blocks * sizeof(uint64_t)) / bytes_per_block;

    if((blocks * sizeof(uint64_t )) % bytes_per_block)
    {
        fat_size++;
    }

    if(verbose)
    {
        fprintf(stdout, "expected allocation table size: %" PRIu64 " blocks\n", fat_size);
    }

    if(verbose)
    {
        fprintf(stdout, "expected allocation table start: block %" PRIu64 "\n", fat_start);
    }

    directory_size = read_qword(20);

    if(verbose)
    {
        fprintf(stdout, "declared directory size: %" PRIu64 " blocks\n", directory_size);
    }

    directory_start = fat_start + fat_size;

    if(verbose)
    {
        fprintf(stdout, "expected directory start: block %" PRIu64 "\n", directory_start);
    }

    data_start = RESERVED_BLOCKS + fat_size + directory_size;

    if(verbose)
    {
        fprintf(stdout, "expected reserved blocks: %" PRIu64 "\n", data_start);
    }

    if(verbose)
    {
        fprintf(stdout, "expected usable blocks: %" PRIu64 "\n", blocks - data_start);
    }

    if(read_word(510) == 0xaa55)
    {
        if(verbose)
        {
            fprintf(stdout, "the image is bootable\n");
        }
    }
    else
    {
        if(verbose)
        {
            fprintf(stdout, "the image is NOT bootable\n");
        }
    }

    if(argc > 2)
    {
        if(!strcmp(argv[2], "mkdir"))
        {
            mkdir_command(argc, argv);
        }
    }

    return EXIT_SUCCESS;
}