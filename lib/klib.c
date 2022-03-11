#include "global.h"

PUBLIC char *itoa(char *str, int num)
{
    int i, j;
    int res;
    int len = 2;
    str[0] = '0';
    str[1] = 'x';
    while(num != 0) {
        res = num % 16;
        str[len++] = res > 9 ? res - 10 + 'A' : res + '0';
        num >>= 4;
    }

    if(len == 2) {
        str[2] = '0';
        str[3] = '\0';
        return str;
    }

    i = 2; j = len - 1;

    while(i < j) {
        str[i] ^= str[j];
        str[j] ^= str[i];
        str[i] ^= str[j];
        i++; j--;
    }
    str[len] = '\0';
    return str;
}

PUBLIC void disp_int(int input)
{
    char output[16];
    itoa(output, input);
    disp_str(output);
}

PUBLIC void delay(int time)
{
    int i, j, k;
    for(i = 0; i < time; i++) {
        for(j = 0; j < time; j++) {
            for(k = 0; k < time; k++) {

            }
        }
    }
}