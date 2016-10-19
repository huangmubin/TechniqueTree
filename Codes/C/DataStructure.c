//
//  DataStructure.c
//  CLanguage2
//
//  Created by 黄穆斌 on 16/10/19.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

#include "DataStructure.h"

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
