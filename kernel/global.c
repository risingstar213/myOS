#define GLOBAL_VARIABLES


#include "global.h"

PUBLIC PROCESS    proc_table[NR_TASKS];

PUBLIC char       task_stack[STACK_SIZE_TOTAL];

PUBLIC TASK       task_table[NR_TASKS] = {
                                            {task_tty, STACK_SIZE_TTY, "tty"},
                                            {TestA, STACK_SIZE_TESTA, "TestA"}, 
                                            {TestB, STACK_SIZE_TESTB, "TestB"}, 
                                            {TestC, STACK_SIZE_TESTC, "TestC"}};

PUBLIC irq_handler irq_table[NR_IRQ];

PUBLIC system_call sys_call_table[NR_SYS_CALL] = {sys_get_ticks};