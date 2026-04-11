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

LD_FLAGS = -s -x -melf_i386 -nostdlib

AS_FLAGS = 

C_FILES := $(shell find ./ -type f -name '*.c')
OBJ := $(C_FILES:.c=.o)

kernel.o: $(OBJ)
	$(LD) $(LD_FLAGS) -r -o kernel.o $(OBJ)

%.o:%.c
	$(CC) $(C_FLAGS) -c $< -o $@

clean:
	rm -f *.o

all:
	$(AS) 