#! /bin/bash

# cleaning the existing files
echo "Peforming clean up..."
rm *.bin
rm *.o
rm *.kern

# assemble the bootsector
echo "Assembling the Bootsector..."
nasm -f bin -o bootsector.bin bootsector.asm

# assemble stage 2
echo "Assembling stage 2..."
nasm -f bin -o stage2.bin stage2.asm

# Compiling C kernel
#echo "Compiling kernel"
nasm -f elf kernel_entry.asm -o kernel_entry.bin
i686-elf-gcc -g -c kernel_entry.c -o kernel_entry.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Linking kernel
echo "Linking the kernel"
i686-elf-gcc -T link.ld -o kernel.kern -ffreestanding -O2 -nostdlib kernel_entry.bin kernel_entry.o -lgcc -g

# join the files together
echo "Joining the files together.."
cat bootsector.bin stage2.bin kernel.kern > LBAOS_loader.bin

# lets send it!
echo "Sending it...."
qemu-system-i386 -fda LBAOS_loader.bin -monitor stdio