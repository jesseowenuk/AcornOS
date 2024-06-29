#include <kernel/tty.h>

void kernel_main(void)
{
    /* Initialise terminal interface */
    terminal_init();

    terminal_write_string("Hello AcornOS!\n");
}