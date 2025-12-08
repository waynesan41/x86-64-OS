# Build binary bootloader and create bootable image


nasm -f bin -o boot.bin boot.asm
nasm -f bin -o loader.bin loader.asm
# nasm
# The assembler you are using (Netwide Assembler).

# -f bin
# Output format = flat binary (no headers, no metadata).
# This is required for bootloader code, because the BIOS loads exactly 512 bytes from the disk.

# -o boot.bin
# Output file name. This is the binary machine code.

# boot.asm
# Your source code.

dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
# Seek mean we skip first sector (512 bytes) to write loader.bin after boot.bin
dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc
# dd if=/dev/zero of=boot.img bs=512 seek=1 count=$((20*16*63-1)) conv=notrunc

# dd
# A low-level copying tool.

# if=boot.bin
# Input file = your compiled bootloader.

# of=boot.img
# Output file = disk image you want to write to.
# If boot.img file does not exist, dd creates it.

# bs=512
# Block size = 512 bytes (size of one boot sector).

# count=1
# Only copy 1 block → exactly 512 bytes.

# conv=notrunc
# Do NOT truncate boot.img.
# This ensures the file isn't cut short; only the first 512 bytes are overwritten.