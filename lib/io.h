#ifndef IO_H
#define IO_H

#include <stdint.h>

#define ouput_byte_via_port(value, port) ({         \
    asm volatile ( "out dx, al"                     \
                    :                               \
                    : "a" (value), "d" (port)       \
                    : );                            \
})

#endif