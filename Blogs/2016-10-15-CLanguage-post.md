---
layout: post
title: "C Language"
description: "记录 C 语言相关内容"
date: 2016-10-15
tags: [C]
comments: true
share: false
---

# 程序框架

## 主框架

``` c
#include <stdio.h>

int main(int argc, char const *argv[]) {
    return 0;
}
```

## 注释

```
// 单行注释
/*
 块注释
 */
```

## 作用域

* 本地变量(局部变量): 变量所处的块中
* 



```
/* 注释块中的内容表示当前作用域所存在的参数 */
int overall = 0;
/*
    overall = 0
 */


int main() {
    int locality = 1;
    /*
     overall  = 0
     locality = 1
     */

    {
        int value = 2;
        /*
         overall  = 0
         locality = 1
         value = 2
         */
    }

    /*
     overall  = 0
     locality = 1
     */

    {
        int locality = 3

        /*
         overall  = 0
         locality = 3
         */
    }

    /*
     overall  = 0
     locality = 1
     */
}
```

---

# 输入输出

* 输出: extern int printf(const char *format, ...);
    * printf("Hello World!\n");
    * printf("10 + 20 = %d", 10 + 20);
    * printf("10.0 / 3.0 = %.2f", 10.0/3.0); // 只读取小数点后 2 位。
* 输入: int scanf(const char * restrict format,...);
    * scanf("%d", &value);
    * scanf("%s", &word);       // 读取字符串，可能会数组越界
    * scanf("%7s", &word);      // 读取字符串，但是长度只能为 7 个字符。



---

# 符号

* 特殊运算符
    * *: 取地址的变量
    * &: 取变量地址
* 运算符
    * +
    * -
    * *
    * /
    * %
    * ()
* 关系运算符
    * ==
    * !=
    * >
    * >=
    * <
    * <=
* 符合运算符
    * ++
    * --
    * +=
    * -=
    * *=
    * /=
    * %=
* 逻辑运算符
    * !
    * ||
    * &&
* 优先级
    * 0: ()
    * 1: +  -  !  ++  --  (单目)
    * 2: *  /  %
    * 3: +  -             (双目)
    * 4: <  <=  >  >=
    * 5: ==  !=
    * 6: && 
    * 7: ||
    * 8: =  +=  -=  *=  /=  %=


> 注意: ++, -- 符号在前缀表示先 +1/-1, 后缀表示运算完毕后 +1/-1

```
void add() {
    var a = 0;
    printf("%d", a++); // 0
    var b = 0;
    printf("%d", ++a); // 1
}
```

> 短路: && || 运算的时候，左边的运算如果已经得出结果，就不会运算右边的结果。例如 && 左边已经得出 false，|| 左边已经得出 true。




---

# 数据类型

## 变量

* 定义: <type name> <value name>;
    * int value;
    * int value = 0;
    * int value1, value2;
    * int value1 = 0, value2 = 0;
    * int value = 100 - other;    // C99
    * 强制转换: double a = (double)value;

## 常量

* 定义: const <type name> <value name>;
    * const int AMOUNT = 100;

## 字符串

> string.h

* char 其实也是一种 int。
    * 通过 ASCII 码进行转换
    * 0 == '\0' != '0'
```
int i = 49;
char c = 49;
printf("i = int(%d), char(%c); c = int(%d), char(%c);\n", i, i, c, c);
// i = int(49), char(1); c = int(49), char(1);
```

* 字符串
    * 字符串常量(字面量): "Hello"; 会被编译器变成一个字符数组，长度等于字符串+1。
        * 两个相邻的字符串会被连接起来变成一个大的字符串。

```
/// 以下三种输出都是一样的: Test word
printf("Test word");
printf("Test "
        "word");
printf("Test \
word");
```

    * 字符串其实是字符数组: 
        * char word[]   = {'H','o','l','l','e','\0'};
        * char *word    = "Hello";
        * char word[]   = "Hello";
        * char word[10] = "Hello";

* 字符串函数
    * size_t strlen(const char *s); 返回字符串长度，不包含'\0';
    * int strcmp(const char *s1, const char *s2); 比较两个字符串，从第一个字母开始按 ASCII 码的差距输出。
        *  0: s1 == s2
        * >0: s1 >  s2
        * <0: s1 <  s2
        * 安全版本: int strncmp(const char *s1, const char *s2, size_t n); 只比较开头几个字母
    * char *strcpy(char *restrict dst, const char *restrict src); 把 src 的字符串拷贝到 dst 中
        * 返回 dst;
        * restrict 表示 src 和 dst 不重叠(C99)
        * 安全版本: char *strncpy(char *restrict dst, const char *restrict src, size_t n);
    * char *strcat(char *restrict s1, const char *restrict s2); 把 s2 拷贝到 s1 的后面，接成一个长字符串
        * 返回 s1
        * s1 必须要有足够的空间
        * 实际上还是一种拷贝
        * 安全版本: char *strncat(char *restrict s1, const char *restrict s2, size_t n);
    * char *strchr(const char *s, int c);  输出从左边开始 c 出现的位置的指针
        * 没有找到就返回 NULL
    * char *strrchr(const char *s, int c); 输出从右边开始 c 出现的位置的指针
        * 没有找到就返回 NULL

## 数组

* 定义: <type name> <value name>[<array count>];
    * int numbers[100];
    * int numbers[] = {0, 1, 2, 3, 4, 5, 6};  // array count is 7.
    * int numbers[5] = {2}                    // array is {2, 0, 0, 0, 0}
    * int numbers[8] = {[1] = 2, 4, [5] = 6}; // array is {0, 2, 4, 0, 0, 6, 0, 0} -> C99 only.
    * int numbers[]  = {[1] = 2, 4, [5] = 6}; // array is {0, 2, 4, 0, 0, 6} -> C99 only.
    * C99 之前数组的数量只能用数字来表示，C99 开始数组的数量可以用变量来表示。
* 多维数组: <type name> <value name>[<array count>]...;
    * int numbers[3][5];
    * int numbers[3][5][7];
    * int numbers[][3] = {{0,1,2},{3,4,5}}; // array count is 2.
    * int numbers[][3] = {0,1,2,3,4,5};
* 使用: 
    * 1维: numbers[0]; // numbers 的第 0 个位置的值。
    * n维: numbers[0][0]; // numbers 的第 0 个位置的数组的第 0 个值。
    * 数组数量计算方式: sizeof(numbers) / sizeof(numbers[0])

> 数组变量其实是 const 指针: int b[10] == int * const b;


## 指针

* 定义

```
int main(int argc, const char * argv[]) {
    /* 定义 int 类型的变量 i, j 和 int 类型的指针 jp */
    int i, j;
    int *jp;
    
    //printf("i is %x = %d, j is %x = %d, jp is %x = %d", &i, i, &j, j, jp, *jp);
    
    /* 给变量和指针赋值 */
    i = 10;
    j = 20;
    jp = &j;
    
    printf("i is %p = %d, j is %p = %d, jp is %p = %d;\n", &i, i, &j, j, jp, *jp);
    
    /* 通过指针改变变量的值 */
    i = 30;
    j = 40;
    *jp = 50;
    
    printf("i is %p = %d, j is %p = %d, jp is %p = %d;\n", &i, i, &j, j, jp, *jp);
    
    /* 声明一个 10 个单元的数组 a */
    int a[10];
    for (int i = 0; i < 10; i++) {
        a[i] = i;
    }
    
    printf("a is %p, &a is %p, &a[0] is %p, &a[1] is %p;\n", a, &a, &a[0], &a[1]);
    
    /* 把数组直接当成指针进行传递 */
    jp = a; // jp == a == a[0];
    
    printf("j is %p = %d;\n", jp, *jp);
    
    jp++; // jp == a[0] -> jp == a[1];
    printf("j is %p = %d;\n", jp, *jp);
    
    *jp = 100;
    printf("a[1] = %d;\n", a[1]);
    
    return 0;
}

/*
i is 0x7fff5fbff7ac = 10, j is 0x7fff5fbff7a8 = 20, jp is 0x7fff5fbff7a8 = 20;
i is 0x7fff5fbff7ac = 30, j is 0x7fff5fbff7a8 = 50, jp is 0x7fff5fbff7a8 = 50;
a is 0x7fff5fbff7c0, &a is 0x7fff5fbff7c0, &a[0] is 0x7fff5fbff7c0, &a[1] is 0x7fff5fbff7c4;
j is 0x7fff5fbff7c0 = 0;
j is 0x7fff5fbff7c4 = 1;
a[1] = 100;
Program ended with exit code: 0
 */
```

* 地址以 16 进制输出: printf("&i = %p\n", &i); // &i = 0x7fff5fbff7ec



---

# 逻辑

* break: 在判断或循环中使用，退出当层运算。
* continue: 在循环中使用，跳过当前循环中后面的步骤，从下一次循环开始。

## 分支结构

### if

* true  == 1 == unnull
* false == 0 == null

```
if (<condition>) {
    /* do some thing */
} else if (<condition>) {
    /* do some thing */
} else {
    /* do some thing */
}
```

### switch

```
switch (<condition>) {
    case <case1>:
        /* do some thing */
        break;
    case <case2>:
        /* do some thing */
        break;
    default:
        /* do some thing */
        break;
}
```

## 循环结构

### while

```
while (<condition>) {
    /* do some thing */
}
```

```
do {
    /* do some thing */
} while (<condition>);
```

### for

```
for (<expression1>; <expression2>; <expression3>) {
    /* do some thing */
}
```

```
int i = 0;
for (i = 1; i < 10; i++) {
    /* do some thing */
}
```

```
for (int i = 1; i < 10; i++) {
    /* do some thing */
}
```

```
for (;;) {
    /* do some thing */
}
```

## goto 语句

```
goto <tag>
/* jump thing */
<tag>:
```

```
for (;;) {
    for (;;) {
        for (;;) {
            goto out;
        }
    }
}
out:
```


---


# 函数

* 函数的含义

函数是一块代码，接收零个或多个参数，做一个任务，并返回零个或一个值。

> 函数的使用需要在函数的实现之后或函数的声明之后。

* 参数的传递
    * 实际参数(值): 实际传递的参数，如此函数调用的里的 value -> function(value);
    * 形式参数(参数): 函数定义参数形式的参数，如此函数声明里的 value -> int function(int value);

> 参数传递默认是一个值复制。

## 函数声明

* <return type> <function name>(<parameter type> <parameter name or not>...);
* int function(int value1, int value2);

> 特殊的函数声明

* void function(void); // 表示一个叫做 functionName 并且没有参数的函数，没有返回值的函数。
* void function();     // 表示一个叫做 functionName 不知道有没有参数，没有返回值的函数。可以传递进入任意数量和类型的参数，所以可能会出错。

## 函数定义

```
<return type> <function name>(<parameter type> <parameter name>...) {
    /* function implement */
    return <return value>; // or not if <return type> is void.
}
```

```
int functionName(int value1, int value2) {
    /* function implement */
    return 0;
}
```

## 标准函数

* size_t sizeof(expression-or-type);
    * 计算类型长度符号的关键字。可以计算类型，变量。
    * 这个是一个编译关键字，不是函数，计算大小是在编译的时候进行计算而不是程序运行时。
* double sqrt(double x);
    * #include <math.h>
    * The sqrt() function compute the non-negative square root of x.


---

---

# 附录

## C 语言保留字

* 数据类型
    * int
    * float
    * double
    * long
    * short
    * unsigned
    * char
    * void
    * sizeof
* 修饰符
    * const (不变的)
* 判断
    * if
    * else
    * switch
    * case
    * break
    * default
* 循环
    * do
    * while
    * for
    * goto
    * continue
    * return




* auto
* enum
* extern
* register
* signed
* static
* struct
* typedef
* union
* volatile
* inline
* restrict

---


## 数据符号

* %d / %i:  int             接受整数值并将它表示为有符号的十进制整数，i是老式写法
* %o:       unsigned int    无符号8进制整数(不输出前缀0）
* %u:       unsigned int    无符号10进制整数
* %x / X:   unsigned int    无符号16进制整数，x对应的是abcdef，X对应的是ABCDEF（不输出前缀0x)
* %f(lf):   float(double)   单精度浮点数用f,双精度浮点数用lf(尤其scanf不能混用)
* %e / E:   double          科学计数法表示的数，此处"e"的大小写代表在输出时用的“e”的大小写
* %g / G:   double          有效位数，如：%8g表示单精度浮点数保留8位有效数字。双精度用lg
* %c:       char            字符型。可以把输入的数字按照ASCII码相应转换为对应的字符
* %s / S:   char * / wchar_t * 字符串。输出字符串中的字符直至字符串中的空字符（字符串以'\0‘结尾，这个'\0'即空字符）
* %p:       void *          以16进制形式输出指针
* %n:       int *           到此字符之前为止，一共输出的字符个数，不输出文本
* %%:       无输入           不进行转换，输出字符‘%’（百分号）本身
* %m:       无              打印errno值对应的出错内容,(例: printf("%m\n"); )
　　


---