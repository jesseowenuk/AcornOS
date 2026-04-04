#ifndef __MASTER_BOOT_RECORD_H__
#define __MASTER_BOOT_RECORD_H__

#include <stdint.h>

struct master_boot_record_partition
{
    uint64_t first_sector;
    uint64_t sector_count;
};

int master_boot_record_get_partition(struct master_boot_record_partition *the_partition, int drive, int partition);

#endif