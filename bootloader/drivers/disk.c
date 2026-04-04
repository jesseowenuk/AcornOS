#include <stdint.h>
#include <stddef.h>

#include <drivers/disk.h>
#include <lib/real.h>
#include <lib/print.h>
#include <lib/libc.h>
#include <lib/master_boot_record.h>

#define SECTOR_SIZE 512

static uint64_t cached_sector = -1;
static uint8_t sector_buffer[512];

static struct
{
    uint16_t size;
    uint16_t count;
    uint16_t offset;
    uint16_t segment;
    uint16_t local_block_aaddress;
} disk_address_packet = {16, 1, 0, 0, 0 };

static int cache_sector(int drive, uint64_t local_block_address)
{
    if(local_block_address == cached_sector)
    {
        return 0;
    }

    disk_address_packet.offset = (uint16_t)(size_t)sector_buffer;
    disk_address_packet.local_block_aaddress = local_block_address;

    struct real_mode_registers registers = {0};
    registers.eax = 0x4200;
    registers.edx = drive;
    registers.esi = (uint32_t)&disk_address_packet;

    real_mode_interrupt(0x13, &registers, &registers);

    if(registers.eflags & EFLAGS_CARRY_FLAG)
    {
        int ah = (registers.eax >> 8) & 0xff;
        print("Disk error %x. Drive: %x, Local Block Address: %x.\n", ah, drive, local_block_address);
        return ah;
    }

    cached_sector = local_block_address;

    return 0;
}

int read(int drive, void *buffer, uint64_t location, uint64_t count)
{
    uint64_t progress = 0;

    while(progress < count)
    {
        uint64_t sector = (location + progress) / SECTOR_SIZE;

        int result;
        if((result = cache_sector(drive, sector)))
        {
            return result;
        }

        uint64_t chunk = count - progress;
        uint64_t offset = (location + progress) % SECTOR_SIZE;
        if(chunk > SECTOR_SIZE - offset)
        {
            chunk = SECTOR_SIZE - offset;
        }

        memcpy(buffer + progress, &sector_buffer[offset], chunk);
        progress += chunk;
    }

    return 0;
}

int read_partition(int drive, int partition, void *buffer, uint64_t location, uint64_t count)
{
    struct master_boot_record_partition the_partition;

    int result = master_boot_record_get_partition(&the_partition, drive, partition);
    if(result)
    {
        return result;
    }

    return read(drive, buffer, location + (the_partition.first_sector * 512), count);
}