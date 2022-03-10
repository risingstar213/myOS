#define GLOBAL_VARIABLES


#include "global.h"

PUBLIC PROCESS    proc_table[NR_TASKS];

PUBLIC char       task_stack[STACK_SIZE_TOTAL];

PUBLIC TASK       task_table[NR_TASKS] = {{TestA, STACK_SIZE_TESTA, "TestA"}, {TestB, STACK_SIZE_TESTB, "TestB"}};