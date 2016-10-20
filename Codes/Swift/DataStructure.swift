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

