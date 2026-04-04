#!/bin/sh

set -e

# We take 1 argument which is the device to use
if [ -z "$1" ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

# Variables
DEVICE="$1"
MBR="$(mktemp)"
LOADER="bootloader/bootloader.bin"

# Create an empty disk
dd if=/dev/zero of="$DEVICE" bs=1m count=1

# Write a simple master boot entry partition entry
printf '\x80\x00\x02\x00\x83\x00\x02\x00\x01\x00\x00\x00\x64\x00\x00\x00' \
        | dd of="$DEVICE" bs=1 seek=446 conv=notrunc

# Boot Signature
printf '\x55\xAA' | dd of="$DEVICE" bs=1 seek=510 conv=notrunc

# Save the partition table created above
dd if="$DEVICE" of="$MBR"   bs=1 count=64 skip=446

# Inject our bootloader into the right place
dd if="$LOADER" of="$DEVICE" conv=notrunc

# Restore the original partition table
dd if="$MBR"    of="$DEVICE" conv=notrunc bs=1 count=64 seek=446