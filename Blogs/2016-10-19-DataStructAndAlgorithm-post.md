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

---

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
     * 平衡树

    

### 二叉树

#### C

只实现递归遍历

```

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
```

#### Swift

实现循环遍历

```
// MARK: - Tree

enum TraverseOrder {
    case pre
    case `in`
    case post
    case level
}

protocol TreeValueProtocol: Comparable {
    
}

class Tree<T: TreeValueProtocol> {
    
    // MARK: Data
    
    var data: T
    var right: Tree?
    var left: Tree?
    
    init(data: T) {
        
        self.data = data
    }
    
    // MARK: 遍历 
    
    /// 遍历该树的以及其子树。
    func traverse(use: TraverseOrder, handle: (Tree) -> Bool) {
        switch use {
        case .pre:
            traversePreOrder(action: handle)
        case .in:
            traverseInOrder(action: handle)
        case .post:
            traversePostOrder(action: handle)
        case .level:
            traverseLevelOrder(action: handle)
        }
    }
    
    /// 前序遍历
    private func traversePreOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                if !action(tree!) {
                    return
                }
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                tree = tree?.right;
            }
        }
    }
    
    /// 中序遍历
    private func traverseInOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                if !action(tree!) {
                    return
                }
                tree = tree?.right;
            }
        }
    }
    
    /// 后序遍历
    private func traversePostOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        var output = [Tree]()
        while tree != nil || !stack.isEmpty {
            center: while tree != nil {
                stack.append(tree!)
                tree = tree?.left
            }
            right: while !stack.isEmpty {
                tree = stack.removeLast()
                if tree?.right != nil {
                    if output.contains(where: { $0 === tree?.right }) {
                        output.append(tree!)
                        if !action(tree!) {
                            return
                        }
                        continue
                    }
                    
                    stack.append(tree!)
                    tree = tree?.right
                    break right
                }
                
                if !output.contains(where: { $0 === tree }) {
                    output.append(tree!)
                    if !action(tree!) {
                        return
                    }
                } else {
                    return
                }
            }
        }
    }
    
    /// 层次遍历
    private func traverseLevelOrder(action: (Tree) -> Bool) {
        var queue = [self]
        var tree: Tree
        while !queue.isEmpty {
            tree = queue.removeFirst()
            if !action(tree) {
                return
            }
            if let left = tree.left {
                queue.append(left)
            }
            if let right = tree.right {
                queue.append(right)
            }
        }
    }
}
```

### 平衡二叉树 (AVL 树)

* 常用算法
    * 红黑树
        * 实现关联数组，复杂度 O(log n)
    * AVL
        * n 个结点的最大深度约为 1.44 log2n，复杂度 O(log n)
        * 增加和删除可能会通过多次树旋转来进行平衡
    * Treap
        * 二叉排序树，比一般的树多记录一个优先级。
        * 满足堆的特性
        * 不同于二叉堆一定是完全二叉树，它不一定是完全二叉树。
    * 伸展树
        * 不用记录用于平衡树的冗余信息。
    * SBT
        * 更易于实现

#### 平衡二叉树 Swift 实现

永远保持平衡的特殊树。关键在于插入删除的时候需要对位置进行调整，可以让查找的效率变得最高。

```
class Tree<T: Comparable> {
    
    // MARK: Data
    
    var data: T
    var right: Tree?
    var left: Tree?
    
    init(data: T) {
        self.data = data
    }
    
    // MARK: 遍历 
    
    /// 遍历该树的以及其子树。
    func traverse(use: TraverseOrder, handle: (Tree) -> Bool) {
        switch use {
        case .pre:
            traversePreOrder(action: handle)
        case .in:
            traverseInOrder(action: handle)
        case .post:
            traversePostOrder(action: handle)
        case .level:
            traverseLevelOrder(action: handle)
        }
    }
    
    /// 前序遍历
    private func traversePreOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                if !action(tree!) {
                    return
                }
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                tree = tree?.right;
            }
        }
    }
    
    /// 中序遍历
    private func traverseInOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                if !action(tree!) {
                    return
                }
                tree = tree?.right;
            }
        }
    }
    
    /// 后序遍历
    private func traversePostOrder(action: (Tree) -> Bool) {
        var tree: Tree? = self
        var stack = [Tree]()
        var output = [Tree]()
        while tree != nil || !stack.isEmpty {
            center: while tree != nil {
                stack.append(tree!)
                tree = tree?.left
            }
            right: while !stack.isEmpty {
                tree = stack.removeLast()
                if tree?.right != nil {
                    if output.contains(where: { $0 === tree?.right }) {
                        output.append(tree!)
                        if !action(tree!) {
                            return
                        }
                        continue
                    }
                    
                    stack.append(tree!)
                    tree = tree?.right
                    break right
                }
                
                if !output.contains(where: { $0 === tree }) {
                    output.append(tree!)
                    if !action(tree!) {
                        return
                    }
                } else {
                    return
                }
            }
        }
    }
    
    /// 层次遍历
    private func traverseLevelOrder(action: (Tree) -> Bool) {
        var queue = [self]
        var tree: Tree
        while !queue.isEmpty {
            tree = queue.removeFirst()
            if !action(tree) {
                return
            }
            if let left = tree.left {
                queue.append(left)
            }
            if let right = tree.right {
                queue.append(right)
            }
        }
    }
    
    func printTree() {
        traverseLevelOrder {
            if $0.left != nil {
                print("\($0.data) - left  -> \($0.left?.data)")
            }
            if $0.right != nil {
                print("\($0.data) - right -> \($0.right?.data)")
            }
            return true
        }
    }
    
    // MARK: 搜索树
    
    func find(value: T) -> Tree<T>? {
        var tree: Tree<T>? = self
        while tree != nil {
            if tree!.data == value {
                return tree
            } else if tree!.data > value {
                tree = tree?.left
            } else {
                tree = tree?.right
            }
        }
        return nil
    }
    
    func find(where compare: (Tree<T>) -> Bool?) -> Tree<T>? {
        var tree: Tree<T>? = self
        while tree != nil {
            if let result = compare(tree!) {
                tree = result ? tree?.left : tree?.right
            } else {
                return tree
            }
        }
        return nil
    }
    
    var minNode: Tree<T> {
        var tree = self
        while tree.left != nil {
            tree = tree.left!
        }
        return tree
    }
    
    var maxNode: Tree<T> {
        var tree = self
        while tree.right != nil {
            tree = tree.right!
        }
        return tree
    }
    
    // MARK: - 二叉平衡树 AVL 树
    
    func insert(value: T) -> Tree<T>? {
        if value == data {
            return self
        }
        
        if value < data {
            left = left?.insert(value: value) ?? Tree(data: value)
            left?.updateDepth()
            if balance() == 2 { // 检查是否平衡
                if value < left!.data {
                    return rotateLL()
                } else {
                    return rotateLR()
                }
            }
        } else {
            right = right?.insert(value: value) ?? Tree(data: value)
            right?.updateDepth()
            if balance() == 2 { // 检查是否平衡
                if value > right!.data {
                    return rotateRR()
                } else {
                    return rotateRL()
                }
            }
        }
        return self
    }
    
    func insertLoop(value: T) -> Tree<T>? {
        
        var tree: Tree<T>! = self
        var stack = [Tree<T>](repeating: self, count: 100)
        var i = 0
        
        // 插入数据
        while true {
            // 如果数据重复退出
            if value == tree.data {
                return self
            }
            
            // 进入左树进行插入
            if value < tree.data {
                if let left = tree.left {
                    stack[i] = tree
                    i += 1
                    tree = left
                } else {
                    tree.left = Tree(data: value)
                    if tree.right == nil {
                        tree._depth = 1
                    } else {
                        tree._depth = 0
                        return self
                    }
                    break
                }
                continue
            }
            
            // 进入右树进行插入
            if let right = tree.right {
                stack[i] = tree
                i += 1
                tree = right
            } else {
                tree.right = Tree(data: value)
                if tree.left == nil {
                    tree._depth = 1
                } else {
                    tree._depth = 0
                    return self
                }
                break
            }
        }
        
        while !(i < 1) {
            tree = stack[i-1]
            i -= 1
            
            tree.updateDepth()
            if tree.balance() < 2 {
                continue
            }
            
            if value < tree.data {
                if value < tree.left!.data {
                    if i < 1 {
                        return tree.rotateLL()
                    } else {
                        if value < stack[i-1].data {
                            stack[i-1].left  = tree.rotateLL()
                        } else {
                            stack[i-1].right = tree.rotateLL()
                        }
                        return self
                    }
                } else {
                    if i < 1 {
                        return tree.rotateLR()
                    } else {
                        if value < stack[i-1].data {
                            stack[i-1].left  = tree.rotateLR()
                        } else {
                            stack[i-1].right = tree.rotateLR()
                        }
                        return self
                    }
                }
            } else {
                if value > tree.right!.data {
                    if i < 1 {
                        return tree.rotateRR()
                    } else {
                        if value < stack[i-1].data {
                            stack[i-1].left  = tree.rotateRR()
                        } else {
                            stack[i-1].right = tree.rotateRR()
                        }
                        return self
                    }
                } else {
                    if i < 1 {
                        return tree.rotateRL()
                    } else {
                        if value < stack[i-1].data {
                            stack[i-1].left  = tree.rotateRL()
                        } else {
                            stack[i-1].right = tree.rotateRL()
                        }
                        return self
                    }
                }
            }
        }
        return self
    }
    
    func delete(value: T) -> Tree<T>? {
        if value == data {
            if var father = right {
                var tree: Tree<T>! = right?.left
                while tree != nil {
                    father = tree
                    tree = tree.left
                }
                if tree == nil {
                    right = father.right
                }
                
                data = tree.data
                father.left = tree.right
                
                if balance() == 2 {
                    return rotateLL()
                } else {
                    return self
                }
            } else {
                return left
            }
        }
        
        if value < data {
            left = left?.delete(value: value)
            if balance() == 2 { // 检查是否平衡
                return rotateRR()
            }
        } else {
            right = right?.delete(value: value)
            if balance() == 2 {
                return rotateLL()
            }
        }
        return self
    }
    
    class func delete(tree: Tree<T>!, value: T) -> Tree<T>? {
        if tree == nil {
            return nil
        }
        
        if tree.data == value {
            if tree.right != nil {
                return delete(tree: tree.right, value: tree.right!.minNode.data)
            } else if tree.left != nil {
                return delete(tree: tree.left, value: tree.left!.data)
            } else {
                return tree
            }
        }
        
        if tree.data < value {
            tree.right = delete(tree: tree.right, value: value)
            return tree
        } else {
            tree.left = delete(tree: tree.left, value: value)
            return tree
        }
    }
    
    // MARK: 深度计算
    
    private var _depth = 0
//    private var _balance = 0
    
    func updateDepth() {
        _depth = max((left?._depth ?? -1), (right?._depth ?? -1)) + 1
    }
    
//    func updateBalance() {
//        updateDepth()
//        _balance = abs((left == nil ? 0 : left!._depth + 1) - (right == nil ? 0 : right!._depth + 1))
//    }
    
    /// 计算树的深度
    func depth() -> Int {
        let l = left?.depth() ?? -1
        let r = right?.depth() ?? -1
        return l >= r ? l + 1 : r + 1
    }
    
//    func balance2() -> Int {
//        return (left == nil ? 0 : left!._depth + 1) - (right == nil ? 0 : right!._depth + 1)
//    }
    
    /// 计算树的平衡度
    func balance() -> Int {
        //return abs((left == nil ? 0 : left!.depth() + 1) - (right == nil ? 0 : right!.depth() + 1))
        
        return abs((left == nil ? 0 : left!._depth + 1) - (right == nil ? 0 : right!._depth + 1))
    }
    
    // MARK: 左右旋转
    
    /// 右单旋
    private func rotateRR() -> Tree<T>? {
        let top     = right
        right       = top?.left
        top?.left   = self
        
        self.updateDepth()
        top?.updateDepth()
        return top
    }
    /// 左单旋
    private func rotateLL() -> Tree<T>? {
        let top    = left
        left       = top?.right
        top?.right = self
        
        self.updateDepth()
        top?.updateDepth()
        return top
    }
    
    /// 右左双旋
    private func rotateRL() -> Tree<T>? {
        right = right?.rotateLL()
        return rotateRR()
    }
    
    /// 左右双旋
    private func rotateLR() -> Tree<T>? {
        left = left?.rotateRR()
        return rotateLL()
    }
}
```

## 堆 优先队列(Priority Queue)

优先队列，按元素的优先权来取出元素，而不是按进入队列的顺序。有最大堆 (MaxHeap) 和最小堆 (MinHeap)

* 数组实现: (插入 O(1), 查找 O(n), 删除 O(n))
* 链表实现: (插入 O(1), 查找 O(n), 删除 O(1))
* 有序数组: (插入 O(log2n), 查找 O(log2n), 删除 O(1))
* 有序链表: (插入 O(n), 查找 O(1), 删除 O(1))
* 完全二叉树: (插入 O(log2(n)), 查找 O(1), 删除 O(1))

### Swift 有序数组实现堆

```Swift
// MARK: - 堆 (优先队列) 有序数组实现

class Heap<T> {
    
    var datas: [T] = []
    var compare: (T, T) -> Bool
    
    init(_ operater: @escaping (T, T) -> Bool) {
        self.compare = operater
    }
    
    var isEmpty: Bool { return datas.isEmpty }
    var count: Int { return datas.count }
    
    func insert(_ value: T) {
        if datas.isEmpty {
            datas.append(value)
            return
        }
        
        var l = -1
        var h = datas.count
        var m = 0
        while l < h-1 {
            m = (l + h) / 2
            if compare(value, datas[m]) {
                h = m
            } else {
                l = m
            }
        }
        datas.insert(value, at: h)
    }
    
    func remove() -> T? {
        if datas.isEmpty {
            return nil
        } else {
            return datas.removeLast()
        }
    }
}
```

## 哈夫曼树 Huffman Tree

哈夫曼树是一种判定树，通过权值来对节点进行组织。

哈夫曼树每次都把权值最小的两个节点合并，成为一颗新的哈夫曼树。节点的父节点的权值就是他们的权值合。

使用最小堆来组织，可以每次都获取到最小值。

* 没有度为 1 的节点。
* 如果 n = 叶节点，总节点数 = 2n - 1
* 左右子树交换后依然是哈夫曼树，哈夫曼树没有左右之分。
* 同一组权值，可能产生多棵不同构的哈夫曼树

```Swift
// 哈夫曼树的构造方法


```

### 哈夫曼编码

使用二叉树来进行编码。把数据排列成为哈夫曼树，并且所有的字符都在叶节点上，然后利用树左0右1的方式，进行编码。

---

## 图 (Graph)

表示多对多的关系。

* 顶点集合 V (Vertex)
* 边的集合 E (Edge)
    * (v, w) ∈ E 表示 v -- w 之间的无向边 E 
    * <v, w> ∈ E 表示 v -> w 之间的有向边 E 
    * 不考虑重边和自回路
* 数据对象集 G (V, E) 由一个非空的有限顶点集合 V 和一个有限边集合 E 组成
* 操作集合
    * Graph Create(); 建立并返回空图
    * Graph InsertVertex(Graph G, Vertex v); 插入顶点
    * Graph InsertEdge(Graph G, Edge e); 插入边
    * void DFS(Graph G, Vertex v); 从 v 开始深度优先遍历 (Depth First Search)
    * void BFS(Graph G, Vertex v); 从 v 开始广度优先遍历
    * void ShortestPath(Graph G, Vertex v, int Dist[]); 计算 v 到任意其他顶点的最短距离
    * void MST(Graph G); 计算最小生成树
    * ...
* 相关术语
    * 无向图: 全双向，方向不重要
    * 有向图: 单双皆有，方向重要
    * 网络: 带权重的图
    * 邻接点: 有直接边相邻的点
    * 连通: 如果从 V 到 W 存在一条路径，则 V 到 W 是连通的。
    * 路径: V 到 W 的路径是一系列的顶点集合 {V, v1, v2 ..., W} 
        * 路径长度: 路径中边数的和(带权重，则是权重和)
        * 简单路径: 如果 V 到 W 之间所有顶点都不同，则是简单路径
    * 回路: 起点等于终点的路径
    * 连通图: 图中任意两点都连通
    * 连通分量: 无向图的极大连通子图
        * 极大的顶点数: 再加一个顶点就不连通了
        * 极大的边数: 所有该顶点连同的所有边
    * 强连通: 有向图
        * V W 双向连同
        * 强连通分量
* 图的表示方法
    * 邻接矩阵 G[N][N]
        * N 表示顶点。
        * G[i][j] 表示 i j 之间有没有边。
        * G[i][i] 肯定都为 0
        * G[i][j] == G[j][i]
        * 数组表示法：长度为 N(N+1)/2，Eij = G[i*(i+1)/2+j] 
        * 适合稠密图，特别是完全图
   * 邻接表 G[N] 指针数组
       * 每一个 N 只存自己有对应边的节点链表
       * 适合稀疏图
* 遍历
    * 深度优先搜索 (Depth First Search, DFS)
        * 类似于树的先序遍历
        * 邻接表存储图: 复杂度 O(N+E)
        * 邻接矩阵存储图: 复杂度 O(N^2)
    * 广度优先搜索 (Breadth First Search, BFS)
        * 类似于树的层序遍历
        * 邻接表存储图: 复杂度 O(N+E)
        * 邻接矩阵存储图: 复杂度 O(N^2)



# 常用算法 Algorithm

有限的指令集，接受 0 个或多个输入，产生输出，并在一定步骤之后终止。

* 算法评判标准
    * 空间复杂度 S(n)
    * 时间复杂度 T(n)




