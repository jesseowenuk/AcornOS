#ifndef __IO_H__
#define __IO_H__

#include <stdint.h>

#define port_out_byte(port, value) ({               \
    asm volatile ( "out dx, al"                     \
                    :                               \
                    : "a" (value), "d" (port)       \
                    : );                            \
})

#endif