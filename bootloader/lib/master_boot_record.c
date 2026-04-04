#include <stddef.h>

#include <drivers/disk.h>
#include <lib/master_boot_record.h>

struct master_boot_record_entry
{
    uint8_t status;
    uint8_t chs_first_sector[3];
    uint8_t file_system_type;
    uint8_t chs_last_sector[3];
    uint32_t first_sector;
    uint32_t sector_count;
} __attribute__((packed));

int master_boot_record_get_partition(struct master_boot_record_partition *the_partition, int drive, int partition)
{
    // Variables
    struct master_boot_record_entry entry;
    const size_t entry_address = 0x1be + sizeof(struct master_boot_record_entry) * partition;

    // Read the entry of the master boot record
    int result;
    if((result = read(drive, &entry, entry_address, sizeof(struct master_boot_record_entry))))
    {
        return result;
    }

    // Check of the partition exists, fail if it doesn't
    if(entry.file_system_type == 0)
    {
        return -1;
    }

    // Assign the final fiels and return
    the_partition->first_sector = entry.first_sector;
    the_partition->sector_count = entry.sector_count;

    return 0;
}