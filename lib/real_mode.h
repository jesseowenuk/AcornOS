#ifndef REAL_MODE_H
#define REAL_MODE_H

#include <stdint.h>

struct real_mode_registers
{
    uint32_t ebp;
    uint32_t edi;
    uint32_t esi;
    uint32_t edx;
    uint32_t ecx;
    uint32_t ebx;
    uint32_t eax;
};

void real_mode_interrupt(uint8_t interrupt_number, struct real_mode_registers *registers_out, struct real_mode_registers *registers_in);

#endif