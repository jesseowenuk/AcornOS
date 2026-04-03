#ifndef __REAL_H__
#define __REAL_H__

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

void real_mode_interrupt(uint8_t interrupt_number, struct real_mode_registers *out_registers, struct real_mode_registers *in_registers);

#endif