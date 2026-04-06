CC=gcc
PREFIX=/usr/local

C_FLAGS = -O3 -ffast-math -Wall -Wextra -pipe

.PHONY: all clean install

all:
	$(CC) $(C_FLAGS) master_boot_record.c echfs-utils.c -o echfs-utils

clean:
	rm -f echfs-utils

install:
	mkdir -p $(PREFIX)/bin
	cp echfs-utils $(PREFIX/bin)