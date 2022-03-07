#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"

#ifdef GLOBAL_VARIABLES
#undef	EXTERN
#define	EXTERN
#endif
// 光标位置
EXTERN int disp_pos;
// 全局描述符表
EXTERN u8 gdt_ptr[6];
EXTERN DESCRIPTOR	gdt[GDT_SIZE];
// 
EXTERN u8 idt_ptr[6];
EXTERN	GATE		idt[IDT_SIZE];