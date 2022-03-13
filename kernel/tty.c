#include "global.h"

// 处理键盘输入等， todo
// 缓冲区
PUBLIC void task_tty()
{
    while(1) {
        keyboard_read();
    }
}