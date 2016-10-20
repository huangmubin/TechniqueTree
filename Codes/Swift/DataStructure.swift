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
        if (tree != nil) {
            postRecursive(tree: tree?.left)
            postRecursive(tree: tree?.right)
            print("\(tree?.data)")
        }
    }
    
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
}



