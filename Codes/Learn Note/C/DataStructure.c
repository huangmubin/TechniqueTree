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


// MARK: - Stack

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


// MARK: 堆栈的表达式求值算法

/*
 2*(9+6/3-5)+4=
 
 (9+6/3-5)+4=
 堆1:
 堆2: 2963/+5-*4+
 
 2963/+5-*4+
 
 16
 
 */

// MARK: - 队列 Queue

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


// MARK: - 树 Tree

typedef struct BinaryTreeNode {
    Type data;
    struct BinaryTreeNode *left;
    struct BinaryTreeNode *right;
} BinaryTree;

//recursive


// MARK: 树递归遍历

void btreePreOrderRecursive(BinaryTree *tree) {
    if (tree) {
        printf("%d", tree->data);
        btreePreOrderRecursive(tree->left);
        btreePreOrderRecursive(tree->right);
    }
}

void btreeInOrderRecursive(BinaryTree *tree) {
    if (tree) {
        btreePreOrderRecursive(tree->left);
        printf("%d", tree->data);
        btreePreOrderRecursive(tree->right);
    }
}

void btreePostOrderRecursive(BinaryTree *tree) {
    if (tree) {
        btreePreOrderRecursive(tree->left);
        btreePreOrderRecursive(tree->right);
        printf("%d", tree->data);
    }
}

// MARK: 树循环遍历
