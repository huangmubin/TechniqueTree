//
//  DataStructure.swift
//  SwiftLanguage
//
//  Created by 黄穆斌 on 16/10/19.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

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

// MARK: - 堆栈 Stack

protocol StackProtocol: class {
    associatedtype Element
    var datas: [Element] { get set }
}

extension StackProtocol {
    
    var isEmpty: Bool {
        return datas.isEmpty
    }
    
    var count: Int {
        return datas.count
    }
    
    func push(item: Element) {
        datas.append(item)
    }
    
    func pop() -> Element? {
        if datas.isEmpty {
            return nil
        } else {
            return datas.removeLast()
        }
    }
    
    func top() -> Element? {
        return datas.last
    }
    
}

// MARK: - 树 Tree

class BinaryTree<T> {
    var data: T
    var left: BinaryTree<T>?
    var right: BinaryTree<T>?
    
    init(data: T) {
        self.data = data
    }
    
    func traverseForPre(action: (BinaryTree) -> Bool) {
        var tree: BinaryTree? = self
        var stack = [BinaryTree]()
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
    func traverseForIn(action: (BinaryTree) -> Bool) {
        var tree: BinaryTree? = self
        var stack = [BinaryTree]()
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
    func traverseForPost(action: (BinaryTree) -> Bool) {
        var tree: BinaryTree? = self
        var stack = [BinaryTree]()
        var output = [BinaryTree]()
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
    func traverseForLevel(action: (BinaryTree) -> Bool) {
        var queue = [self]
        var tree: BinaryTree
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
    
    // MARK: 递归遍历
    
    class func preRecursive(tree: BinaryTree?) {
        if (tree != nil) {
            print("\(tree?.data)")
            preRecursive(tree: tree?.left)
            preRecursive(tree: tree?.right)
        }
    }
    
    class func inRecursive(tree: BinaryTree?) {
        if (tree != nil) {
            inRecursive(tree: tree?.left)
            print("\(tree?.data)")
            inRecursive(tree: tree?.right)
        }
    }
    
    class func postRecursive(tree: BinaryTree?) {
        var tree: BinaryTree? = tree
        var stack = [BinaryTree]()
        var output = [BinaryTree]()
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
                        print(tree?.data)
                        continue
                    }
                    
                    stack.append(tree!)
                    tree = tree?.right
                    break right
                }
                
                if !output.contains(where: { $0 === tree }) {
                    output.append(tree!)
                    print(tree?.data)
                } else {
                    return
                }
            }
        }
    }
    
    // MARK: 循环遍历
    
    class func inLoop(tree: BinaryTree) {
        var tree: BinaryTree? = tree
        var stack = [BinaryTree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                print(tree?.data)
                tree = tree?.right;
            }
        }
    }
    
    class func preLoop(tree: BinaryTree) {
        var tree: BinaryTree? = tree
        var stack = [BinaryTree]()
        while tree != nil || !stack.isEmpty {
            while tree != nil {
                print(tree?.data)
                stack.append(tree!)
                tree = tree?.left
            }
            if !stack.isEmpty {
                tree = stack.removeLast()
                tree = tree?.right;
            }
        }
    }
    
    class func postLoop(tree: BinaryTree) {
        var tree: BinaryTree? = tree
        var stack = [BinaryTree]()
        var output = [BinaryTree]()
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
                        print(tree?.data)
                        continue
                    }
                    
                    stack.append(tree!)
                    tree = tree?.right
                    break right
                }
                
                if !output.contains(where: { $0 === tree }) {
                    output.append(tree!)
                    print(tree?.data)
                } else {
                    return
                }
            }
        }
    }
    
    class func levelLoop(tree: BinaryTree) {
        var queue = [tree]
        var tree: BinaryTree
        while !queue.isEmpty {
            tree = queue.removeFirst()
            print(tree.data)
            if let left = tree.left {
                queue.append(left)
            }
            if let right = tree.right {
                queue.append(right)
            }
        }
    }
}

// MARK: - Tree

enum TraverseOrder {
    case pre
    case `in`
    case post
    case level
}

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
    
    func updateDepth() {
        _depth = max((left?._depth ?? -1), (right?._depth ?? -1)) + 1
    }
    
    /// 计算树的深度
    func depth() -> Int {
        let l = left?.depth() ?? -1
        let r = right?.depth() ?? -1
        return l >= r ? l + 1 : r + 1
    }
    
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

// MARK: - 堆 (优先队列) 有序数组实现

class Heap<T> {
    
    var datas: [T] = []
    var complare: (T, T) -> Bool
    
    init(type: @escaping (T, T) -> Bool) {
        self.complare = type
    }
    
    var isEmpty: Bool { return datas.isEmpty }
    var count: Int { return datas.count }
    
    func insert(_ value: T) {
        if datas.isEmpty {
            datas.append(value)
            return
        }
        
        if complare(value, datas[0]) {
            datas.insert(value, at: 0)
            return
        }
        var p = datas.count/2
        var i = datas.count-1
        while p != i {
            if complare(value, datas[p]) {
                i = p
                p = p / 2
            } else {
                
            }
        }
        datas.insert(value, at: p)
    }
    
    
}
