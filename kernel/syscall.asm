%include "sconst.inc"

_NR_get_ticks equ 0
INT_VECTOR_SYS_CALL equ 0x90

global get_ticks ; 系统调用函数

bits 32

[SECTION .text]
; function get_ticks
get_ticks:
    mov eax, _NR_get_ticks
    int INT_VECTOR_SYS_CALL
    ret
