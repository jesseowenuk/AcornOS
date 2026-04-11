CC = x86_64-elf-gcc
LD = x86_64-elf-ld
AS = nasm

C_FLAGS = -Wall                 \
		  -m32					\
		  -ffreestanding		\
		  -nostdlib				\
		  -O                    \
		  -fstrength-reduce     \
		  -fomit-frame-pointer  \
		  -finline-functions    \
		  -nostdinc             \
		  -I../include

LD_FLAGS = -O2

LD_FLAGS = -s -x -melf_i386 -nostdlib -r

AS_FLAGS = -felf32

C_FILES := $(shell find ./ -type f -name '*.c')
OBJ := $(C_FILES:.c=.o)

init.o: head.asm $(OBJ)
	$(AS) $(AS_FLAGS) head.asm -o head.o
	$(LD) $(LD_FLAGS) $(INTERNAL_LD_FLAGS) head.o -o init.o $(OBJ)

%.o:%.c
	$(CC) $(C_FLAGS) -c $< -o $@

clean:
	rm -f *.o

all:
	$(AS) 