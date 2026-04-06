#include <stdint.h>
#include <stdio.h>

struct master_boot_record_partition
{
    uint64_t first_sector;
    uint64_t sector_count;
};

struct master_boot_record_parition master_boot_record_get_partition(FILE *file, int partition);