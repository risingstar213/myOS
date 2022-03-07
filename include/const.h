#ifndef _CONST_H_
#define _CONST_H_

// 
#define EXTERN extern

#define PUBLIC
#define PRIVATE static

#define GDT_SIZE 128
#define	IDT_SIZE	256


/* 权限 */
#define	PRIVILEGE_KRNL	0
#define	PRIVILEGE_TASK	1
#define	PRIVILEGE_USER	3

#define INT_M_CTL     0x20 // I/O port for interrupt controller
#define INT_M_CTLMASK 0x21 // disable interrupt
#define INT_S_CTL     0xA0 // I/O port for second interrupt controller
#define INT_S_CTLMASK 0xA1 // disable interrupt

#endif /* _CONST_H_*/