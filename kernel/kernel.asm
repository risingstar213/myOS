
SELECTOR_KERNEL_CS equ 8

extern cstart
extern exception_handler

extern gdt_ptr
extern idt_ptr
extern disp_pos

; 堆定义位置
[SECTION .bss]
StackSpace    resb  2 * 1024
StackTop:

[SECTION .text]

global _start
global	divide_error
global	single_step_exception
global	nmi
global	breakpoint_exception
global	overflow
global	bounds_check
global	inval_opcode
global	copr_not_available
global	double_fault
global	copr_seg_overrun
global	inval_tss
global	segment_not_present
global	stack_exception
global	general_protection
global	page_fault
global	copr_error

_start:
    mov esp, StackTop

    sgdt [gdt_ptr]
    call cstart
    lgdt [gdt_ptr]

    lidt [idt_ptr]

    jmp SELECTOR_KERNEL_CS:csinit ; 使用初始化结构
csinit:

    ud2
    ; jmp 0x40:0

    ; push 0
    ; popfd ; 清零标志寄存器
    hlt

divide_error: ; fault
    push 0xFFFFFFFF ; err code (none)
    push 0 ; int vecter number
    jmp exception

single_step_exception: ; fault / trap
    push 0xFFFFFFFF
    push 1
    jmp exception

nmi: ; interrupt
    push 0xFFFFFFFF
    push 2
    jmp exception

breakpoint_exception: ; trap
    push 0xFFFFFFFF
    push 3
    jmp exception

overflow: ; trap
    push 0xFFFFFFFF
    push 4
    jmp exception

bounds_check: ; fault
    push 0xFFFFFFFF
    push 5
    jmp exception

inval_opcode: ; fault
    push 0xFFFFFFFF
    push 6
    jmp exception

copr_not_available: ; fault
    push 0xFFFFFFFF
    push 7
    jmp exception

double_fault: ; abort
    push 8
    jmp exception

copr_seg_overrun: ; fault
    push 0xFFFFFFFF
    push 9
    jmp exception

inval_tss:
    push 10
    jmp exception

segment_not_present:
    push 11
    jmp exception

stack_exception:
    push 12
    jmp exception

general_protection:
	push 13
	jmp	exception

page_fault:
	push 14
	jmp	exception

copr_error:
	push 0xFFFFFFFF
	push 16
	jmp	exception

exception:
    call exception_handler
    add esp, 8 ; 出栈
    hlt