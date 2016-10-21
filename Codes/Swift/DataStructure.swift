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
    
    // MARK: 搜索树
    
    func find(value: T) -> Tree? {
        var tree: Tree? = self
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
    
    func find(where compare: (Tree) -> Bool?) -> Tree? {
        var tree: Tree? = self
        while tree != nil {
            if let result = compare(tree!) {
                tree = result ? tree?.left : tree?.right
            } else {
                return tree
            }
        }
        return nil
    }
    
    var min: Tree {
        var tree = self
        while tree.left != nil {
            tree = tree.left!
        }
        return tree
    }
    
    var max: Tree {
        var tree = self
        while tree.right != nil {
            tree = tree.right!
        }
        return tree
    }
    
    func insert(value: T) {
        
    }
}


