---
layout: post
title: "Objective-C 笔记"
description: "Objective-C 笔记"
date: 2016-10-16
tags: [Language]
comments: true
share: false
---

[TOC]

# 基础程序架构

```
# import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ...
    }
    return 0;
}
```

## 输入输出

```
scanf("%d", i);
NSLog(@"%d", i);
```

# 类、对象和方法

## 类

## 对象

## 方法

# 数据类型和表达式

## 数据类型

* 类型
    * int
    * float
    * char
* 限定词
    * long
    * longlong
    * short
    * unsigned
    * signed
* id 类型(表示任意类型)
* bool 类型(非0或非空就为 true) 

### 类型转换

```
int i = 10;
float j = 20.5;

i + (int)j // 30
```

## 运算符

```
// 运算符
+ - * /
```

```
// 逻辑符
== != < <= > >=
```

```
// 位运算符
& | ^ ~ << >>
```

## static 关键字

用于静态变量的声明，该变量声明一次后不会被销毁。

```
-(int)test {
    static int count = 0;
    count += 1;
    return count;
}

[self test]; // 1
[self test]; // 2
[self test]; // 3
```

## 全局变量

```
// 声明
int global;

// 在别的文件中引入
extern int global;
```

## typedef 语句

```
typedef int Counter; // Counter === int
```

# 控制流

## 循环

### for

```
for (int i = 1; i <= 10; n += 1) {
    ...
}
```

### while

```
while (bool) {
    ...
}

do {
    ...
} while (bool)
```

### 控制语句

```
break

continue
```

## 分支

### if

```
if (bool) {
    ...
} else if (bool) {
    ...
} else {
    ...
}
```

### switch

```
switch (expression) {
    case value1:
        ...
        break;
    case value2:
        ...
        break;
    default:
        ...
        break;
}
```

### 三目运算符

```
condition ? expression1 : expression2
```

# 类

```Objective-c
/***********************************************************/
// MARK: - 头文件 
#import <Foundation/Foundatin.h>


/***********************************************************/
// MARK: - 预定义


/***********************************************************/
// MARK: - 类接口
@interface ClassName: FatherClass

// 公开属性声明
@property int value;
@property (nonatomic) NSString *value2;

// 实例方法声明
-(void)functionname:(int)v1 other:(float)v2;

// 类方法声明
+(void)function;

@end


/***********************************************************/
// MARK: - 分类

@interface ClassName(CategoryName)

// 属性或方法

@end

// MARK: 方法私有化
@interface ClassName()

...

@end

/***********************************************************/
// MARK: - 类实现
@implementation ClassName {
    // 定义实例变量
    int v1 = 0;
    double v2;
}

// 实例方法实现
-(void)functionname:(int)v1 other:(float)v2 {
    ...
}

// 类方法实现
+(void)function {
    ...
}

@end
```

## 属性

```
@property (nonatomic, readonly,  strong) NSString *word;

* 多线程特性：atomic / nonatomic。前者可以保证属性在通过多线程存取是不会发生错误。但注意，在使用atomic的情况下，不能再手动生成存取方法，因为它们的实现包含了线程管理的内容。一般都用nonatomic。
* 读写特性：readonly / readwrite。前者只允许实现取方法。
* 内存管理特性：又分为非ARC模式和ARC模式下。
    * 非ARC
        * retain：限定指针类型的变量，指针所指向的对象的引用计数加1。
        * assign：限定非指针和id类型的变量，不对引用计数进行操作。
        * copy：限定指针类型的变量，复制接收copy消息的对象，并将变量指向这个新的对象。多用于防止可变类型的对象放生改变。
    * ARC
        * strong：作用同非ARC模式下的retain。
        * weak：限定指针类型的变量，作用同非ARC模式下的assign，但是，但变量所指向的对象被释放后，指针自动被设置为nil。
        * assign：限定非指针类型的变量，如int，float，结构体等基本数据类型。也可以用关键字unsafe_unretained来表示。
```

# 继承

# 多态、动态类型和动态绑定

```
[object isKindOfClass:<#(__unsafe_unretained Class)#>];
[object isMemberOfClass:<#(__unsafe_unretained Class)#>];
[object respondsToSelector:<#(SEL)#>];
[object performSelector:<#(SEL)#>];
[object performSelector:<#(nonnull SEL)#> onThread:<#(nonnull NSThread *)#> withObject:<#(nullable id)#> waitUntilDone:<#(BOOL)#>];
[object performSelector:<#(nonnull SEL)#> withObject:<#(nullable id)#> afterDelay:<#(NSTimeInterval)#>];
   
   
[Object instancesRespondToSelector:<#(SEL)#>];
[Object isSubclassOfClass:<#(__unsafe_unretained Class)#>];
```

# 异常处理

```
@try {
    ...
} @catch (NSException *exception) { 
    ...
}
```

```
// 抛出异常
@throw
```

# 枚举

```
enum Name {
    value1, value2, value3
};

// value1 = 0, value2 = 1

enum Name2 {
    v1, v2 = 10, v3
};

// v1 = 0, v2 = 10, v3 = 11
```

```
// 声明枚举变量
enum Name enumValue;

enumValue = 1; // enumValue = Name.value2
```

# 变量和数据类型

# 协议

```
// 声明协议
@protocol ProtocolName <NSObject>
-(void)requireMethod;
@optional
-(void)optionalMethod;
@end

// 使用协议
@property (nonatomic) id<ProtocolName> value;

// 在接口中声明该类实现协议
@interface Class <ProtocolName>
@end

// 或者在分类中声明
@interface Class() <ProtocolName>
@end
```

# 预处理

## #define

```
#define Pi 3.14
#define Two_Pi 2 * 3.14
#define AND &&
#define Square(x) ((x) * (x))

NSLog(@"%f", Pi); // 3.14
NSLog(@"%f", Two_Pi); // 2 * 3.14 = 6.28
   
bool a = YES;
bool b = YES;
if (a AND b) {
  NSLog(@"AND == &&");
}
   
int i = Square(30); // ((30) * (30)) = 900
```

## #import

```
#import "dd.h"  引入某文件
#import <dd/dd.h> 引入某源文件目录中的文件
```

## 条件编译

```
#define Pi 3.14
#define Two_Pi 2 * 3.14
#define AND &&
#define Square(x) ((x) * (x))


#define IPAD YES

#ifdef IPAD  // 如果有定义 IPAD
#  define V1 10
#else
#  define V1 20
#endif

#ifndef IPAD // 如果没有定义 IPAD
#  define V2 10
#else
#  define V2 20
#endif

#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5 // 如果条件成立
#define EEEE 10
#endif

#undef IPAD // 取消 IPAD 预定义
```

# Foundation 框架





