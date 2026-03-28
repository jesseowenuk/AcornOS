#!/bin/bash

(cd bootsect ; nasm -o bootsect bootsect.asm)
bootsect_result=$?

echo NASM Result: $bootsect_result

(make -C kernel)
make_result=$?

echo Make Result: $make_result

cat bootsect/bootsect kernel/kernel.kn > os.img
