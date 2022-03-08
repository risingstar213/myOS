#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "string.h"
#include "global.h"

PUBLIC void cstart()
{
    disp_pos = 0;
    disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
		 "-----\"cstart\" begins-----\n");
    // 旧 GDT -> 新 GDT
    memcpy((void *)&gdt, (void *)(*((u32*)(&gdt_ptr[2]))), *(u16 *)&(gdt_ptr[0]) + 1);
    // 修改全局描述符表基址
    *(u16*)(&gdt_ptr[0]) = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *(u32*)(&gdt_ptr[2]) = (u32)&gdt;


    *(u16*)(&idt_ptr[0]) = IDT_SIZE * sizeof(GATE) - 1;
    *(u32*)(&idt_ptr[2]) = (u32)&idt;

    init_prot();
    disp_str("-----\"cstart\" ends-----\n");
}