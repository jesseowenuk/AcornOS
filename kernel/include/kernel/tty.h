#ifndef _KERNEL_TTY_H
#define _KERNEL_TTY_H

#include <stddef.h>

void terminal_init();
void terminal_put_char(char c);
void terminal_write(const char* data, size_t size);
void terminal_write_string(const char* data);

#endif