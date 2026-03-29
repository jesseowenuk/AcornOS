CC = x86_64-elf-cc
LD = x86_64-elf-ld

C_FLAGS = -O2 -pipe -Wall -Wextra

INTERNAL_C_FLAGS = \
	-m16 \
	-ffreestanding \
	-nostdlib \
	-masm-intel \
	-fno-pic \
	-mno-pic \
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

bootloader.bin: $(OBJ)
	$(LD) $(LD_FLAGS) $(INTERNAL_LD_FLAGS) $(OBJ) -o $@

%.o: %.c
	$(CC) $(C_FLAGS) $(INTERNAL_C_FLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)