#include "global.h"

PUBLIC void clock_handler(int irq)
{
    disp_str("#");
    ticks++;
    // 中断重入
    if(k_reenter != 0) {
        disp_str("!");
        return;
    }

    p_proc_ready++;
    if(p_proc_ready >= proc_table + NR_TASKS) {
        p_proc_ready = proc_table;
    }
}

PUBLIC void milli_delay(int milli_sec)
{
    int t = get_ticks();

    while(((get_ticks() - t) * 1000 / HZ) < milli_sec) {};
}