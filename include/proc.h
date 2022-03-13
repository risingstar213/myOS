#ifndef _PROC_H_
#define _PROC_H_
#include "type.h"
#include "const.h"
#include "protect.h"

typedef struct s_stackframe {
    u32 gs;
    u32 fs;
    u32 es;
    u32 ds;
    u32 edi;
    u32 esi;
    u32 ebp;
    u32 kernel_esp; // important
    u32 ebx;
    u32 edx;
    u32 ecx;
    u32 eax;

    u32 retaddr; // return address

    u32 eip;
    u32 cs;

    u32 eflags;

    u32 esp;
    u32 ss;
} STACK_FRAME;


// 进程表
typedef struct s_proc {
    STACK_FRAME regs;
    u16 ldt_sel;  // ldt selector
    DESCRIPTOR ldts[LDT_SIZE]; // ldt数组

    int ticks;
    int priority;

    u32 pid; // pid
    char p_name[16]; // name
} PROCESS;

// tasktab
typedef struct s_task {
    task_f initial_eip;
    int stack_size;
    char name[32];
} TASK;


#define NR_TASKS 4


#define STACK_SIZE_TTY		0x8000
#define STACK_SIZE_TESTA	0x8000
#define STACK_SIZE_TESTB    0x8000
#define STACK_SIZE_TESTC    0x8000

#define STACK_SIZE_TOTAL (STACK_SIZE_TTY + \
                            STACK_SIZE_TESTA + \
                            STACK_SIZE_TESTB + \
                            STACK_SIZE_TESTC)


#define NR_SYS_CALL 1
#endif /* _PROC_H_ */