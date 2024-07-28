#include <stdint.h>

void kernel_main(void)
{  
    uint16_t attrib = (1 << 4) | (15 & 0x0F);
    volatile uint16_t* where;
    where = (volatile uint16_t*)0xB8000;
    *where = 'H' | (attrib << 8);
   
    for(;;);
}