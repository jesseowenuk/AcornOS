#include <stdint.h>

#include <lib/libc.h>
#include <lib/print.h>
#include <filesystem/echfs.h>
#include <drivers/disk.h>
#include <lib/types.h>

struct echfs_identity_table
{
    uint8_t jmp[4];
    uint8_t signature[8];
    uint64_t block_count;
    uint64_t directory_length;
    uint64_t block_size;
} __attribute__((packed));

struct echfs_directory_entry
{
    uint64_t parent_id;
    uint8_t type;
    char name[201];
    uint64_t amended_time;
    uint64_t modified_time;
    uint64_t permissions;
    uint16_t owner;
    int16_t group;
    uint64_t created_time;
    uint64_t payload;
    uint64_t size;
} __attribute__((packed));

#define ROOT_ID                 0xffffffffffffffff
#define END_OF_CHAIN            0xffffffffffffffff
#define FILE_TYPE               0

int load_echfs_file(int disk, int partition, void *buffer, const char *filename)
{
    struct echfs_identity_table identity_table;
    read_partition(disk, partition, &identity_table, 0, sizeof(struct echfs_identity_table));

    if(strncmp(identity_table.signature, "_ECH_FS_", 8))
    {
        print("ECHFS: signature invalid\n", filename);
        return -1;
    }

    const uint64_t block_size = identity_table.block_size;
    const uint64_t block_count = identity_table.block_count;
    const uint64_t directory_length = identity_table.directory_length * block_size;
    const uint64_t allocation_table_size = DIV_ROUNDUP(block_count * sizeof(uint64_t), block_size) * block_size;
    const uint64_t allocation_table_offset = 16 * block_size;
    const uint64_t directory_offset = allocation_table_offset + allocation_table_size;

    // Find the file in the root directory
    struct echfs_directory_entry entry;
    for(uint64_t i = 0; i < directory_length; i += sizeof(struct echfs_directory_entry))
    {
        read_partition(disk, partition, &entry, i + directory_offset, sizeof(struct echfs_directory_entry));

        if(!entry.parent_id)
        {
            break;
        }

        if(!strcmp(filename, entry.name) && entry.parent_id == ROOT_ID && entry.type == FILE_TYPE)
        {
            // Load the file
            for(uint64_t i = entry.payload; i != END_OF_CHAIN;)
            {
                // Read the block
                read_partition(disk, partition, buffer, i * block_size, block_size);
                buffer += block_size;

                // Read the next block
                read_partition(disk, partition, &i, allocation_table_offset + i * sizeof(uint64_t), sizeof(uint64_t));
            
                return 0;
            }
        }
    }

    print("echfs: file %s not found\n", filename);
    return -1;
}