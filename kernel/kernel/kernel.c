#include <stdio.h>

#include <kernel/tty.h>

void kernel_main(void)
{
    /* Initialise terminal interface */
    terminal_init();

    printf("Hello AcornOS!\n");
}