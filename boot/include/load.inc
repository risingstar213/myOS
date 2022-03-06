BaseOfLoader equ 09000h ; 加载基地址
OffsetOfLoader equ 0100h ; 加载偏移位置

BaseOfLoaderPhyAddr equ BaseOfLoader*10h

BaseOfKernelFilePhyAddr	equ	BaseOfKernelFile * 10h
KernelEntryPointPhyAddr	equ	030400h
; 加载kernel file的位置和实际运行位置不同
BaseOfKernelFile  equ 08000h
OffsetOfKernelFile  equ 0h