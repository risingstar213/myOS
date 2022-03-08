#define GLOBAL_VARIABLES


#include "global.h"

PUBLIC PROCESS    proc_table[NR_TASKS];

PUBLIC char       task_stack[STACK_SIZE_TOTAL];