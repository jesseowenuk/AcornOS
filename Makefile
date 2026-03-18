CC = x86_64-elf-gcc
LD = x86_64-elf-ld

CFLAGS = -O2 -pipe -Wall -Wextra

INTERNAL_CFLAGS = \
    -m16 \
    -ffreestanding \
    -nostdlib \
    -masm=intel \
    -fno-pic \
    -mno-sse \
    -mno-sse2 \
    -fno-stack-protector \
    -I. \

LDFLAGS =

INTERNAL_LDFLAGS = \
    -m elf_i386 \
    -nostdlib \
    -Tboot/linker.ld

.PHONY: all clean

C_FILES := \
    boot/main.c \
    drivers/vga_text_mode.c \

OBJ := \
    build/main.o \
    build/vga_text_mode.o \

all: build/aloader.bin

build/aloader.bin: build/bootsect.bin $(OBJ)
	$(LD) $(LDFLAGS) $(INTERNAL_LDFLAGS) $(OBJ) -o build/stage2.bin
	cat build/bootsect.bin build/stage2.bin > $@

build/bootsect.bin: boot/bootsect/bootsect.asm
	cd boot/bootsect && nasm bootsect.asm -fbin -o ../../build/bootsect.bin

build/main.o: boot/main.c
	$(CC) $(CFLAGS) $(INTERNAL_CFLAGS) -c $< -o $@

build/vga_text_mode.o: drivers/vga_text_mode.c
	$(CC) $(CFLAGS) $(INTERNAL_CFLAGS) -c $< -o $@

clean:
	rm -f build/*