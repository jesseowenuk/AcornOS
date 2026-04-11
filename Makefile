CC = x86_64-elf-gcc
LD = x86_64-elf-ld
AS = nasm
OBJCOPY = x86_64-elf-objcopy

LD_FLAGS = -s -x -M -melf_i386
C_FLAGS = -Wall                 \
		  -O                    \
		  -fstrength-reduce     \
		  -fomit-frame-pointer  \
		  -fcombine-regs

ARCHIVES = init/init.o kernel/kernel.o

all: acorn.bin

# Get rid of elf
acorn.bin: acorn.elf
	$(OBJCOPY) -O binary acorn.elf acorn.bin
	echfs/echfs-utils -vmp 1 disk.iso format 512
	echfs/echfs-utils -vmp 1 disk.iso import acorn.bin acorn.bin

# Link all the files together using ELF
acorn.elf: $(ARCHIVES)
	$(LD) $(LD_FLAGS) -Tlinker.ld $(ARCHIVES) -o acorn.elf > acorn.map

init/init.o:
	(cd init; make)

kernel/kernel.o:
	(cd kernel; make)

clean:
	(cd init; make clean)
	(cd kernel; make clean)
	rm -f *.bin *.elf *.map