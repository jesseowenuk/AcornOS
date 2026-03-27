CC = x86_64-elf-gcc
LD = x86_64-elf-ld
ASM = nasm

C_SRC = $(shell find . -type f -name "*.c")
ASM_SRC = $(shell find . -type f -name "*.asm")

OBJ = ${ASM_SRC:.asm=.o} ${C_SRC:.c=.o}

C_FLAGS = -c -ffreestanding
LD_FLAGS = -Ttext 0x8200
LD_FLAGS_BIN = $(LD_FLAGS) --oformat binary
AS_FLAGS = -f elf64

all: kernel kernel.elf

kernel: ${OBJ}
	${LD} -o $@ ${LD_FLAGS_BIN} $^

kernel.elf: ${OBJ}
	${LD} -o $@ ${LD_FLAGS} $^

%.o: %.c
	${CC} ${C_FLAGS} -o $@ $^

%.o: %.asm
	${ASM} $< ${AS_FLAGS} -o $@

clean:
	rm -f kernel kernel.elf *.o **/*.o