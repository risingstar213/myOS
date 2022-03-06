#include "type.h"
#include "const.h"
#include "protect.h"

PUBLIC void* memcpy(void *pDst, void *pSrc, int iLen);

PUBLIC void disp_str(char * pStr);

PUBLIC u8 gdt_ptr[6];
PUBLIC DESCRIPTOR gdt[GDT_SIZE];


PUBLIC void cstart()
{
    disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
		 "-----\"cstart\" begins-----\n");
    // 旧 GDT -> 新 GDT
    memcpy((void *)&gdt, (void *)(*((u32*)(&gdt_ptr[2]))), *(u16 *)&(gdt_ptr[0]) + 1);
    // 修改全局描述符表基址
    *(u16*)(&gdt_ptr[0]) = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *(u32*)(&gdt_ptr[2]) = (u32)&gdt;
}