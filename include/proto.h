#ifndef _PROTO_H_
#define _PROTO_H_
#include "const.h"
#include "type.h"
PUBLIC void out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void disp_str(char * info);
PUBLIC void disp_color_str(char * info, int color);
PUBLIC void disp_int(int input);
PUBLIC void	init_8259A();

PUBLIC void	delay(int time);

void restart();
void TestA();
void TestB();
void TestC();

PUBLIC void put_irq_handler(int irq, irq_handler handler);
PUBLIC void spurious_irq(int irq);

PUBLIC void clock_handler(int irq);
PUBLIC void init_clock();

PUBLIC void keyboard_handler(int irq);
PUBLIC void keyboard_read();
PUBLIC void init_keyboard();


PUBLIC int disable_irq(int irq);
PUBLIC void	enable_irq(int irq);
PUBLIC void disable_int();
PUBLIC void enable_int();

PUBLIC int sys_get_ticks();
PUBLIC void sys_call();
PUBLIC int get_ticks();

PUBLIC void milli_delay(int milli_sec);

PUBLIC void schedule();

PUBLIC void task_tty();
#endif