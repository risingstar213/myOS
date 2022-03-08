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
CINC := -I include/
OBJS := kernel/global.o kernel/kernel.o kernel/main.o kernel/start.o kernel/i8259.o kernel/protect.o lib/klib.o lib/kliba.o lib/string.o
DASMOUTPUT	= kernel.bin.asm

.PHONY : all everything clean boot kernel disasm

everything : boot kernel
	dd if=boot/boot.bin of=a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop a.img /mnt/floppy/
	sudo cp -fv boot/loader.bin /mnt/floppy/
	sudo cp -fv kernel/kernel.bin /mnt/floppy
	sudo umount /mnt/floppy

disasm :
	$(DASM) $(DASMFLAGS) $(KERNEL) > $(DASMOUTPUT)


all: clean everything 

clean :
	rm $(OBJS) $(BOOT) $(KERNEL)

boot: $(BOOT)

kernel: $(OBJS)
	$(LD) -m elf_i386 -Ttext 0x30400 -s -o kernel/kernel.bin $^

boot/boot.bin : boot/boot.asm boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(BOOTINC) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/load.inc \
			boot/include/fat12hdr.inc boot/include/pm.inc boot/include/lib.inc
	$(ASM) $(BOOTINC) -o $@ $<		

kernel/kernel.o: kernel/kernel.asm
	$(ASM) -I include/ -f elf -o $@ $<

kernel/main.o : kernel/main.c
	$(CC) $(CINC)  -m32 -c -fno-builtin -o $@ $<

kernel/start.o : kernel/start.c include/type.h include/const.h include/protect.h \
		include/proto.h include/string.h
	$(CC) $(CINC)  -m32 -c -fno-builtin -o $@ $<

kernel/i8259.o : kernel/i8259.c include/type.h include/const.h include/protect.h \
			include/proto.h
	$(CC) $(CINC)  -m32 -c -fno-builtin -o $@ $<

kernel/global.o:  kernel/global.c include/global.h
	$(CC) $(CINC)  -m32 -c -fno-builtin -o $@ $<

kernel/protect.o : kernel/protect.c
	$(CC) $(CINC) -fno-stack-protector -m32 -c -fno-builtin -o $@ $<

lib/klib.o : lib/klib.c
	$(CC) $(CINC) -fno-stack-protector -m32 -c -fno-builtin -o $@ $<

lib/kliba.o : lib/kliba.asm
	$(ASM) -f elf -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) -f elf -o $@ $<
