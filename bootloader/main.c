asm (
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

#include <drivers/vga_textmode.h>
#include <lib/real.h>
#include <lib/print.h>
#include <lib/master_boot_record.h>
#include <filesystem/echfs.h>

extern uint8_t bss_begin;
extern uint8_t bss_end;

#define KERNEL "acorn.bin"

void main(int boot_drive)
{
    // Zero out the .bss section
    for(uint8_t *p = &bss_begin; p < &bss_end; p++)
    {
        *p = 0;
    }

    // Inital message
    init_vga_textmode();
    print("AcornOS Loader\n\n");
    print("=> Boot drive: %x\n\n", boot_drive);

    // Enumerate partitions
    struct master_boot_record_partition partitions[4];

    for(int i = 0; i < 4; i++)
    {
        print("=> Checking for partition %d...", i);
        int result = master_boot_record_get_partition(&partitions[i], boot_drive, i);
        if(result)
        {
            print("Not found!\n");
        }
        else
        {
            print("Found!\n");
        }
    }

    // Load the file from partition 0 at 1MiB 
    // TODO: Maybe later make it selectable if we want to share ;)
    int partition = 1;
    print("=> Booting %s in partition %d\n", KERNEL, partition);
    load_echfs_file(boot_drive, partition, (void *)0x100000, KERNEL);

    for(;;)
    {
        struct real_mode_registers registers = {0};

        // Real mode interrupt 0x16
        real_mode_interrupt(0x16, &registers, &registers);

        char character = (char)(registers.eax & 0xff);
        text_write(&character, 1);
    }
}