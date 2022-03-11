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

#define NR_IRQ 16
#define	CLOCK_IRQ	0
#define	KEYBOARD_IRQ	1
#define	CASCADE_IRQ	2	/* cascade enable for 2nd AT controller */
#define	ETHER_IRQ	3	/* default ethernet interrupt vector */
#define	SECONDARY_IRQ	3	/* RS232 interrupt vector for port 2 */
#define	RS232_IRQ	4	/* RS232 interrupt vector for port 1 */
#define	XT_WINI_IRQ	5	/* xt winchester */
#define	FLOPPY_IRQ	6	/* floppy disk */
#define	PRINTER_IRQ	7
#define	AT_WINI_IRQ	14	/* at winchester */

#define TIMER0     0x40
#define TIMER_MODE 0x43
#define RATE_GENERATOR 0x34

#define TIMER_FREQ 1193182L
#define HZ 100
#endif /* _CONST_H_*/