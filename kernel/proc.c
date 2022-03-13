#include "global.h"

PUBLIC int sys_get_ticks()
{
    return ticks;
}

PUBLIC void schedule()
{
    PROCESS *p;

    int greatest_ticks = 0;

    while(!greatest_ticks) {
        // 找当前ticks最大进程
        for(p = proc_table; p < proc_table + NR_TASKS; p++) {
            if(p->ticks > greatest_ticks) {
                greatest_ticks = p->ticks;
                p_proc_ready = p;
            }
        }
        // 若都执行完则进行下一个调度周期
        if(!greatest_ticks) {
            for(p = proc_table; p < proc_table + NR_TASKS; p++) {
                p->ticks = p->priority;
            }
        }
    }
}