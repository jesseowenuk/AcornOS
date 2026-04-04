#ifndef __DISK_H__
#define __DISK_H__

#include <stddef.h>
#include <stdint.h>

int read(int drive, void *buffer, uint64_t location, uint64_t count);

#endif