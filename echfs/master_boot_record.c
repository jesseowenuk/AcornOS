#include "master_boot_record.h"

struct master_boot_record_entry
{
    uint8_t status;
    uint8_t chs_first_sector[3];
    uint8_t type;
    uint8_t chs_last_sector[3];
    uint32_t first_sector;
    uint32_t sector_count;
}__attribute__((packed));

// returns 0 in error condition
struct master_boot_record_partition master_boot_record_get_partition(FILE *file, int partition)
{
    struct master_boot_record_partition result = {0};
    fseek(file, 0x1be, SEEK_SET);
    struct master_boot_record_entry entries[4];
    fread(entries, sizeof(struct master_boot_record_entry), 4, file);

    if(!entries[partition].type)
    {
        return result;
    }
    
    result.first_sector = entries[partition].first_sector;
    result.sector_count = entries[partition].sector_count;

    return result;
}