#include "global.h"

void TestA();

PUBLIC int kernel_main()
{
    disp_str("-----\"kernel_main\" begins-----\n");

    TASK* p_task = task_table;
    PROCESS* p_proc = proc_table;
    char *p_task_stack = task_stack + STACK_SIZE_TOTAL;
    u16 select_ldt = SELECTOR_LDT_FIRST;
    int i;
    for(i = 0; i < NR_TASKS; i++) {
        strcpy(p_proc[i].p_name, p_task->name);
        p_proc[i].pid = i;
        p_proc[i].ldt_sel = select_ldt;
        memcpy(&p_proc[i].ldts[0], &gdt[SELECTOR_KERNEL_CS>>3], sizeof(DESCRIPTOR));
        p_proc[i].ldts[0].attr1 = DA_C | PRIVILEGE_TASK << 5; // DPL
        memcpy(&p_proc[i].ldts[1], &gdt[SELECTOR_KERNEL_DS>>3], sizeof(DESCRIPTOR));
        p_proc[i].ldts[1].attr1 = DA_DRW | PRIVILEGE_TASK << 5;
        p_proc[i].regs.cs = (0 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | SA_RPL1;
        p_proc[i].regs.ds = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | SA_RPL1;
        p_proc[i].regs.es = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | SA_RPL1;
        p_proc[i].regs.fs = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | SA_RPL1;
        p_proc[i].regs.ss = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | SA_RPL1;
        p_proc[i].regs.gs = (SELECTOR_KERNEL_GS & SA_RPL_MASK) | SA_RPL1; // 仅改变 RPL
        p_proc[i].regs.eip = (u32)p_task[i].initial_eip;
        p_proc[i].regs.esp = (u32)p_task_stack;
        p_proc[i].regs.eflags = 0x1202;

        select_ldt += 1 << 3;
        p_task_stack -= p_task[i].stack_size;
    }
    k_reenter = 0;

    p_proc_ready	= proc_table;

    put_irq_handler(CLOCK_IRQ, clock_handler);
    enable_irq(CLOCK_IRQ); 

	restart();

    while(1) {}

}

void TestA()
{
    int i = 0;
    while(1) {
        disp_str("A");
        disp_int(i++);
        disp_str(".");
        delay(50);
    }
}

void TestB()
{
    int i = 0x1000;
    while(1) {
        disp_str("B");
        disp_int(i++);
        disp_str(".");
        delay(50);
    }
}

void TestC()
{
    int i = 0x2000;
    while(1) {
        disp_str("C");
        disp_int(i++);
        disp_str(".");
        delay(50);
    }
}