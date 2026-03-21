#ifndef VGA_TEXTMODE_H
#define VGA_TEXTMODE_H

#include <stddef.h>

void init_vga_text_mode(void);
void write_string_to_screen(const char *string_buffer);

#endif