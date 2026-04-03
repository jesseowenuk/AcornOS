#ifndef __VGA_TEXTMODE_H__
#define __VGA_TEXTMODE__

#include <stddef.h>

void init_vga_textmode(void);
void text_write(const char *buffer, size_t length);

#endif