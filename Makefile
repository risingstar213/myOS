# Entry point of Orange'S
# It must have the same value with 'KernelEntryPointPhyAddr' in load.inc!
ENTRYPOINT	= 0x30400

# Offset of entry point in kernel file
# It depends on ENTRYPOINT
ENTRYOFFSET	=   0x400

CC := gcc
LD := ld
ASM := nasm
DASM := ndisasm

BOOT := boot/boot.bin boot/loader.bin
BOOTINC := -I boot/include/
KERNEL := kernel/kernel.bin
KERNELINC := -I include/
OBJS := kernel/kernel.o kernel/start.o lib/kliba.o lib/string.o
DASMOUTPUT	= kernel.bin.asm

.PHONY : all everything clean boot kernel disasm

all: clean everything 

disasm :
	$(DASM) $(DASMFLAGS) $(KERNEL) > $(DASMOUTPUT)

everything : boot kernel
	dd if=boot/boot.bin of=a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop a.img /mnt/floppy/
	sudo cp -fv boot/loader.bin /mnt/floppy/
	sudo cp -fv kernel/kernel.bin /mnt/floppy
	sudo umount /mnt/floppy

clean :
	rm $(OBJS) $(BOOT) $(KERNEL)

boot: $(BOOT)

kernel: kernel/kernel.o kernel/start.o lib/kliba.o lib/string.o
	$(LD) -m elf_i386 -Ttext 0x30400 -s -o kernel/kernel.bin $^

boot/boot.bin : boot/boot.asm boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(BOOTINC) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/load.inc \
			boot/include/fat12hdr.inc boot/include/pm.inc boot/include/lib.inc
	$(ASM) $(BOOTINC) -o $@ $<		

kernel/kernel.o: kernel/kernel.asm
	$(ASM) -f elf -o $@ $<

kernel/start.o : kernel/start.c include/type.h include/const.h include/protect.h
	$(CC) $(KERNELINC)  -m32 -c -fno-builtin -o $@ $<

lib/kliba.o : lib/kliba.asm
	$(ASM) -f elf -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) -f elf -o $@ $<
