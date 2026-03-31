CC = x86_64-elf-gcc
LD = x86_64-elf-ld

C_FLAGS = -O2 -pipe -Wall -Wextra

INTERNAL_C_FLAGS = \
	-m32 \
	-ffreestanding \
	-nostdlib \
	-masm=intel \
	-fno-pic \
	-mno-sse \
	-mno-sse2 \
	-fno-stack-protector \
	-I.

LD_FLAGS = 

INTERNAL_LD_FLAGS = \
	-m elf_i386 \
	-nostdlib \
	-Tlinker.ld

.PHONY: all clean

C_FILES := $(shell find ./ -type f -name '*.c')
OBJ := $(C_FILES:.c=.o)

all: bootloader.bin

bootloader.bin: bootsector/bootsector.bin $(OBJ)
	$(LD) $(LD_FLAGS) $(INTERNAL_LD_FLAGS) $(OBJ) -o stage2.bin
	cat bootsector/bootsector.bin stage2.bin > $@

bootsector/bootsector.bin: bootsector/bootsector.asm
	cd bootsector && nasm bootsector.asm -fbin -o bootsector.bin

%.o: %.c
	$(CC) $(C_FLAGS) $(INTERNAL_C_FLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) bootloader.bin bootsector/bootsector.bin