
SELECTOR_KERNEL_CS equ 8

extern cstart

extern gdt_ptr

; 堆定义位置
[SECTION .bss]
StackSpace    resb  2 * 1024
StackTop:

[SECTION .text]

global _start

_start:
    mov esp, StackTop

    sgdt [gdt_ptr]
    call cstart
    lgdt [gdt_ptr]

    jmp SELECTOR_KERNEL_CS:csinit ; 使用初始化结构
csinit:

    push 0
    popfd ; 清零标志寄存器

    hlt