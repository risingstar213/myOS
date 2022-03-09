#include "type.h"
#include "const.h"
#include "protect.h"
#include "string.h"
#include "proto.h"
#include "proc.h"

#ifdef GLOBAL_VARIABLES
#undef	EXTERN
#define	EXTERN
#endif
// 光标位置
EXTERN int disp_pos;
// 全局描述符表
EXTERN u8 gdt_ptr[6];
EXTERN DESCRIPTOR	gdt[GDT_SIZE];
// idt
EXTERN u8 idt_ptr[6];
EXTERN	GATE		idt[IDT_SIZE];

EXTERN int k_reenter;
EXTERN TSS tss;
EXTERN PROCESS* p_proc_ready;

// Process table
extern PROCESS proc_table[];
// Task stack
extern char task_stack[];
