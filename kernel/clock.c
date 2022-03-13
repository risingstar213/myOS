#include "global.h"

PUBLIC void clock_handler(int irq)
{
    // disp_str("#");
    ticks++;
    p_proc_ready->ticks--;
    // 中断重入
    if(k_reenter != 0) {
        // disp_str("!");
        return;
    }
    /*
    // 执行下一个进程
    p_proc_ready++;
    if(p_proc_ready >= proc_table + NR_TASKS) {
        p_proc_ready = proc_table;
    }*/
    schedule();
}

PUBLIC void init_clock()
{   

    out_byte(TIMER_MODE, RATE_GENERATOR);
    out_byte(TIMER0, (u8)(TIMER_FREQ/HZ));
    out_byte(TIMER0, (u8)((TIMER_FREQ/HZ) >> 8));

    put_irq_handler(CLOCK_IRQ, clock_handler);
    enable_irq(CLOCK_IRQ); 
}

PUBLIC void milli_delay(int milli_sec)
{
    int t = get_ticks();

    while(((get_ticks() - t) * 1000 / HZ) < milli_sec) {};
}