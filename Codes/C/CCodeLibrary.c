//
//  CCodeLibrary.c
//  CLanguage
//
//  Created by 黄穆斌 on 16/10/16.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

#include "CCodeLibrary.h"

/** 输出 int 类型最大值与最大值的位数 */
void printfIntTypeMax() {
    int a = 0, b = 0;
    
    while (++a > 0);
    
    printf("int 数据的最大数是: %d;\n", a-1);
    printf("unsigned 数据的最大数是: %u;\n", -1);
    
    do {
        b++;
        a /= 10;
    } while (a != 0);
    printf("int 数据最大位数是: %d;\n", b);
}
