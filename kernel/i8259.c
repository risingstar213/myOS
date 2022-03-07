
#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"

PUBLIC void init_8259A()
{
    // MASTER ICW1
    out_byte(INT_M_CTL, 0x11);

    // SLAVE ICW1
    out_byte(INT_S_CTL, 0x11);

    // MASTER ICW2
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);

    // SLAVE ICM2
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);

    // MASTER ICM3
    out_byte(INT_M_CTLMASK, 0x4);

    // SLAVE ICM3
    out_byte(INT_S_CTLMASK, 0x2);

    // MASTER ICM4
    out_byte(INT_M_CTLMASK, 0x1);

    // SLAVE ICM4
    out_byte(INT_S_CTLMASK, 0x1);

    // MASTER OCW1
    out_byte(INT_M_CTLMASK,	0xFF);

    // SLAVE OCW1
    out_byte(INT_S_CTLMASK,	0xFF);
}