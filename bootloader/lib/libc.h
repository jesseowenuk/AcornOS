#ifndef __LIBC_H__
#define __LIBC_H__

#include <stddef.h>

uint64_t __umoddi3(uint64_t a, uint64_t b);

void *memcpy(void *destination, const void *source, size_t string_length);
int strcmp(const char *string_one, const char *string_two);
int strncmp(const char *string_one, const char *string_two, size_t string_length);

#endif