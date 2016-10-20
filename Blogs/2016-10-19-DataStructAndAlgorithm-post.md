---
layout: post
title: "Data Struct And Algorithm"
description: "常用数据结构学习笔记"
date: 2016-10-16
tags: [DataStruct, Algorithm]
comments: true
share: false
---

[TOC]

# 数据结构 Data Structure

数据结构是计算机中存储，组织数据的方式。

> 数据结构应该是脱离语言限制的一种抽象表现，所以接下来的每个章节，我都会使用 C 语言以及 Swift 语言进行实现。因为目前就这两种语言是我最熟悉的，以后补充其他语言的版本。

## 线性结构

### 线性表 Linear List

* 定义: 由同类型数据元素构成的有序序列线性结构。
    * 长度: 表中元素的个数
    * 空表: 没有元素的时候
    * 表头: 起始位置
    * 表尾: 结束位置
* 常用操作
    * 初始化一个空表: List MakeEmpty()
    * 计算长度: int Length(List L)
    * 返回某个元素: ElementType FindK(int K, List L)
    * 查找元素位置: int Find(ElementType X, list L)
    * 插入元素: void Insert(ElementType X, int i, List L)
    * 删除某个元素: void Delete(int i, List L)
* 实现方式
    * 数组
    * 链表

#### C

> C 语言实现链表

``` C
#include <stdio.h>
#include <stdlib.h>

#define Type int

// MARK: - 线性表 (链表 ChainList)

/// 链表结构
typedef struct ChainListNode {
    Type data;
    struct ChainListNode *next;
} ChainList;

/// 创建空链表初始值为 -1
ChainList *chainListInit() {
    ChainList *list = (ChainList *)malloc(sizeof(ChainList));
    list->data = -1;
    list->next = NULL;
    return list;
}

/// 计算链表长度
int chainListLength(ChainList *list) {
    ChainList *p = list;
    int i = 0;
    while (p) {
        p = p->next;
        i++;
    }
    return i;
}

/// 根据序号查找链表节点，序号从 0 开始
ChainList *chainListFindWithIndex(int index, ChainList *list) {
    ChainList *p = list;
    int i = 0;
    while (p != NULL && i < index) {
        p = p->next;
        i++;
    }
    return p;
}

/// 根据值查找链表节点
ChainList *chainListFindWithData(Type data, ChainList *list) {
    ChainList *p = list;
    while (p != NULL && p->data != data) {
        p = p->next;
    }
    return p;
}

/// 插入: 新建节点; 查找到插入节点的上一个节点; 新节点指向下一个节点; 上一个节点指向新节点。
ChainList *chainListInsert(Type data, int index, ChainList *list) {
    ChainList *p, *n;
    
    // 在头结点处插入
    if (index == 0) {
        n = (ChainList *)malloc(sizeof(ChainList));
        n->data = data;
        n->next = list;
        return n;
    }
    
    // 获取插入位置
    p = chainListFindWithIndex(index, list);
    if (p == NULL) {
        return NULL;
    }
    
    // 插入
    n = (ChainList *)malloc(sizeof(ChainList));
    n->data = data;
    n->next = p->next;
    p->next = n;
    return list;
}

/// 删除节点: 找到前一个节点; 获取删除节点; 前一个节点指向后一个节点; 释放删除节点
ChainList *chainListDelete(int index, ChainList *list) {
    ChainList *p, *d;
    
    // 如果列表为空
    if (list == NULL) {
        return NULL;
    }
    
    // 删除头元素
    if (index == 0) {
        p = list->next;
        free(list);
        return p;
    }
    
    // 查找删除元素的上一个位置
    p = chainListFindWithIndex(index - 1, list);
    if (p == NULL) {
        return NULL;
    }
    
    // 删除
    d = p->next;
    p->next = d->next;
    free(d);
    return list;
}
```

#### Swift

> Swift 实现链表 (事实上 Swift 可以使用数组很简易的实现链表功能，不需要封装，但是我这里还是写了，而且把它写成泛型协议，这样只要遵守这个协议的类就可以拥有链表的操作了。当然，这一点都不实用，其实是一种炫技。)

```Swift
// MARK: - 线性表

/* 
在这个泛型协议中，我定义了一个准守 Equatable 协议的泛型 Element, 这是为了后面按值查找的时候可以直接使用等号进行判断。
但实际上这并不是一种聪明的做法，在进行判断的时候完全可以使用闭包来进行处理，这样就能获取更多的类型支持。这里只是为了能表现泛型类型约束的用法，才就这样做。
协议后面的 class 表示这个协议只能被 class 遵从，这种约束是必要的，如果你想使用 struct 类型来实现链表，不是说不可以，但这明显不是一个适用值拷贝场景的地方。
*/
protocol ChainList: class {
    associatedtype Element: Equatable
    var data: Element { get set }
    var next: Self? { get set }
    init()
}

extension ChainList {
    
    /// 返回当前节点到链表结尾的长度
    var length: Int {
        var i = 1
        var p: Self? = self
        while p?.next != nil {
            p = p?.next
            i += 1
        }
        return i
    }
    
    /// 查找元素
    subscript(index: Int) -> Self? {
        var i = 0
        var p: Self? = self
        while p != nil && i < index {
            p = p?.next
            i += 1
        }
        return p
    }
    
    /// 通过值来查找元素
    func find(value: Element) -> Self? {
        var p: Self? = self
        while p != nil && value != p?.data {
            p = p?.next
        }
        return p
    }
    
    /// 插入元素
    @discardableResult func insert(value: Element, to: Int) -> Self? {
        if to == 0 {
            let node  = Self.init()
            node.data = value
            node.next = self
            return node
        }
        
        if let pre = self[to - 1] {
            let node  = Self.init()
            node.data = value
            node.next = pre.next
            pre.next  = node
            return self
        }
        
        return nil
    }
    
    /// 删除元素
    @discardableResult func delete(index: Int) -> Self? {
        if index == 0 {
            return self.next
        }
        
        if let pre = self[index - 1] {
            pre.next = pre.next?.next
            return self
        }
        
        return nil
    }
    
}

// MARK: - 使用示例

/*
遗憾的是，由于协议当中使用了 Self 类型，所以遵从这个协议的类不得不设置为 final。也就是无法继承了。
*/
final class List: ChainList {
    typealias Element = String
    var data: List.Element = ""
    var next: List?
    required init() { }
}

var top: List? = List()
top?.data = "0"

for i in 1 ..< 5 {
    let _ = top?.insert(value: "\(i)", to: i)
}

if let length = top?.length {
    for i in 0 ..< length {
        print(top?[i]?.data)
    }
    
    for _ in 0 ..< length-1 {
        let _ = top?.delete(index: 1)
    }
}

print("Tag")

if let length = top?.length {
    for i in 0 ..< length {
        print(top?[i]?.data)
    }
}

print("Done")

/* 打印输出

Optional("0")
Optional("1")
Optional("2")
Optional("3")
Optional("4")
Tag
Optional("0")
Done
Program ended with exit code: 0

 */
```

---

### 堆栈 Stack

* 定义
    * 堆栈是有一定操作约束的线性表
    * 只在栈顶做插入删除
    * 后进先出 Last In First Out (LIFO)
* 操作
    * 生成空堆栈
    * 检查堆栈是否已满
    * 检查堆栈是否为空
    * 入栈 Push
    * 出栈 Pop
* 实现方式
    * 数组
    * 链表

#### C

> C 语言版数组堆栈: 数组版本的堆栈还可以实现同个数组的双堆栈，让其中一个堆栈的起点放在数组的尾部即可，实现也很简单，这里不做实现。

##### C 语言版数组堆栈

```
// MARK: Array

#define MaxSize 10
#define TypeError -1

typedef struct {
    Type *data;
    int max;
    int top;
} ArrayStack;

/// 创建堆栈
ArrayStack *arrayStackInit(int size) {
    ArrayStack *s = (ArrayStack *)malloc(sizeof(ArrayStack));
    Type array[size];
    s->data = array;
    s->top  = -1;
    s->max  = size-1;
    return s;
}

/// 检查堆栈是否已满
int arrayStackIsFull(ArrayStack stack) {
    return stack.top - stack.max;
}

/// 检查堆栈是否为空
int arrayStackIsEmpty(ArrayStack stack) {
    return stack.top + 1;
}

/// 入栈
int arrayStackPush(Type item, ArrayStack stack) {
    if (stack.top == stack.max) {
        return 0;
    } else {
        stack.data[++stack.top] = item;
        return 1;
    }
}

/// 出栈
Type arrayStackPop(ArrayStack stack) {
    if (stack.top == -1) {
        return TypeError;
    } else {
        return stack.data[stack.top--];
    }
}
```

##### C 语言版链表堆栈

```
// MARK: Chain

typedef struct ChainStackNode {
    Type data;
    struct ChainStackNode *prev;
} ChainStack;

ChainStack *chainStackInit() {
    ChainStack *s = (ChainStack *)malloc(sizeof(ChainStack));
    s->data = -1;
    s->prev = NULL;
    return s;
}

int chainStackIsEmpty(ChainStack *stack) {
    return (stack->prev == NULL);
}

void chainStackPush(Type value, ChainStack *stack) {
    ChainStack *s = (ChainStack *)malloc(sizeof(ChainStack));
    s->data = value;
    s->prev = stack->prev;
    stack->prev = s;
}

Type chainStackPop(ChainStack *stack) {
    if (stack->prev == NULL) {
        return TypeError;
    } else {
        ChainStack *s;
        s = stack;
        stack = stack->prev;
        Type i = s->data;
        free(s);
        return i;
    }
}
```



#### Swift

> Swift 语言版数组堆栈

```
// MARK: - 堆栈 Stack

protocol Stack: class {
    associatedtype Element
    var stack: [Element] { get set }
}

extension Stack {
    
    var isEmpty: Bool {
        return stack.isEmpty
    }
    
    var count: Int {
        return stack.count
    }
    
    func push(item: Element) {
        stack.append(item)
    }
    
    func pop() -> Element? {
        if stack.isEmpty {
            return nil
        } else {
            return stack.removeLast()
        }
    }
    
}
```

### 队列

* 定义只能在一端插入，另一端删除。
    * 入队列
    * 出队列
    * 先进先出 FIFO
* 实现
    * 数组实现
    * 链表实现

#### C

##### 数组实现循环队列

```
// MARK: 数组队列

typedef struct {
    Type *data;
    int top;
    int tail;
    int size;
} ArrayQueue;


/// 创建队列
ArrayQueue *arrayQueueInit(int size) {
    ArrayQueue *q = (ArrayQueue *)malloc(sizeof(ArrayQueue));
    Type d[size];
    q->data = d;
    q->top  = 0;
    q->tail = 0;
    q->size = size;
    return q;
}

int arrayQueueIsFull(ArrayQueue *queue) {
    int n = queue->top + 1;
    n %= queue->size;
    if (n == queue->tail) {
        return 1;
    } else {
        return 0;
    }
}

int arrayQueueIsEmpty(ArrayQueue *queue) {
    if (queue->top == queue->tail) {
        return 1;
    } else {
        return 0;
    }
}

int arrayQueueAppend(Type item, ArrayQueue *queue) {
    if (arrayQueueIsFull(queue)) {
        return 0;
    }
    
    queue->data[queue->top++] = item;
    queue->top %= queue->size;
    return 1;
}

Type arrayQueueDelete(ArrayQueue *queue) {
    if (arrayQueueIsEmpty(queue)) {
        return 0;
    }
    
    Type t = queue->data[queue->tail++];
    queue->tail %= queue->size;
    return t;
}
```

##### 数组实现链表队列

```
// MARK: 链表队列

typedef struct {
    struct ChainListNode *top;
    struct ChainListNode *tail;
} ChainQueue;

ChainQueue *chainQueueInit() {
    ChainQueue *q = (ChainQueue *)malloc(sizeof(ChainQueue));
    q->top = NULL;
    q->tail = NULL;
    return q;
}

int chainQueueIsEmpty(ChainQueue *queue) {
    return (queue->tail == NULL);
}

void chainQueueAppend(Type item, ChainQueue *queue) {
    ChainList *c = (ChainList *)malloc(sizeof(ChainList));
    c->data = item;
    c->next = NULL;
    queue->top = c;
    if (queue->tail == NULL) {
        queue->tail = c;
    }
}

Type chainQueueDelete(ChainQueue *queue) {
    if (chainQueueIsEmpty(queue)) {
        return TypeError;
    }
    
    Type c = queue->tail->data;
    queue->tail = queue->tail->next;
    if (queue->tail == NULL) {
        queue->top = NULL;
    }
    return c;
}
```

## 树

* 术语
    * 结点的度 (Degree): 结点的子树个数
    * 树的度: 树的所有结点中最大的度
    * 叶节点 (Leaf): 度为 0 的结点
    * 父节点 (Parent): 有子树的结点就是其子树的根结点的父节点
    * 子节点 (Child): 子树的根节点就是子节点
    * 兄弟结点 (Sibling): 同一父节点的结点就是彼此的兄弟结点
    * 路径和路径长度: 两个结点之间的结点集合就是路径，结点数量就是路径长度
    * 祖先结点 (Ancestor)
    * 子孙结点 (Descendant)
    * 结点的层次 (Level): 根结点在 1 层，其他结点累计添加
    * 深度 (Depth): 所有节点中最大的层次叫做树的深度
* 树的种类
    * 二叉树
        * 性质
            * 第 i 层的最大节点数为 2 的 i-1 次方
            * 深度为 k 的二叉树最大的结点总数为 2 的 k 次方减 1
            * 任何非空的二叉树，如果 n0 表示叶节点个数，n2 为非叶节点个数，那么 n0 = n2 + 1
        * 特殊种类
            * 斜二叉树
            * 完美二叉树
            * 完全二叉树
  * 二叉搜索树
      * 性质
          * 通过二分查找加快搜索速度
          * 查找频率高，插入删除频率低
          * 左子树比结点小
          * 右子树比结点大
          * 左右子树也是二叉搜索树
     * 常用操作
         * 查找: 二分查找
         * 插入: 
         * 删除: 


---

---

# 常用算法 Algorithm

有限的指令集，接受 0 个或多个输入，产生输出，并在一定步骤之后终止。

* 算法评判标准
    * 空间复杂度 S(n)
    * 时间复杂度 T(n)


