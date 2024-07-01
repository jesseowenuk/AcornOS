#include <stdio.h>

#include <kernel/tty.h>
#include "multiboot.h"

/* Check if the bit BIT in FLAGS are set. */
#define CHECK_FLAG(flags,bit) ((flags) & (1 << (bit)))

void kernel_main(unsigned long magic, unsigned long address)
{
    multiboot_info *mbi;
    mbi = (multiboot_info*) address;

    /* Initialise terminal interface */
    terminal_init();

    if(CHECK_FLAG(mbi->flags, 12))
    {
        printf("Graphics Info Present\n");
    }
    else
    {
        printf("Graphics Info not present\n");
    }

    printf("Decimal Test:\n");

    for(int i = 0; i < 10; i++)
    {
        printf("%d\n", i);
    }

    printf("Hello AcornOS!\n");
}