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

# Save the partition table created above
dd if="$DEVICE" of="$MBR"   bs=1 count=64 skip=446

# Inject our bootloader into the right place
dd if="$LOADER" of="$DEVICE" conv=notrunc

# Restore the original partition table
dd if="$MBR"    of="$DEVICE" conv=notrunc bs=1 count=64 seek=446