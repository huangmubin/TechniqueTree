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

> C 语言版链表堆栈

#### Swift

> Swift 语言版数组堆栈

---

---

# 常用算法 Algorithm

有限的指令集，接受 0 个或多个输入，产生输出，并在一定步骤之后终止。

* 算法评判标准
    * 空间复杂度 S(n)
    * 时间复杂度 T(n)


