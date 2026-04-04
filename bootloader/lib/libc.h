#ifndef __LIBC_H__
#define __LIBC_H__

#include <stddef.h>

void *memcpy(void *destination, const void *source, size_t count);
int strcmp(const char *string_one, const char *string_two);

#endif