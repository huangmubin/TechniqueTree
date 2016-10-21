---
layout: post
title: "Little Code"
description: "一些没用的小程序。"
date: 2016-10-21
tags: [Other]
comments: true
share: false
---

> 记录我写的一些没什么用处的小程序。


# 计算器的实现

利用堆栈结构实现计算器算法。

只能运算个位数的加减乘除，其他还没做。

```
import Foundation

/*
 3+4*5+6/3*2 = 27
 345*+63/2*+ = 27
 */


enum Operation: Character {
    case plus         = "+"
    case minus        = "-"
    case times        = "*"
    case division     = "/"
    case surplus      = "%"
    
    /// 计算优先级
    static func <(left: Operation, right: Operation) -> Bool {
        switch left.rawValue {
        case "%", "*", "/":
            return false
        default:
            switch right.rawValue {
            case "+", "-":
                return false
            default:
                return true
            }
        }
    }
    
    /// 计算结果
    subscript(left: Double, right: Double) -> Double {
        switch self {
        case .plus:
            return left + right
        case .minus:
            return left - right
        case .times:
            return left * right
        case .division:
            return left / right
        case .surplus:
            return Double(Int(left) % Int(right))
        }
    }
}

enum Number: Character {
    case zero  = "0"
    case one   = "1"
    case two   = "2"
    case three = "3"
    case four  = "4"
    case five  = "5"
    case six   = "6"
    case seven = "7"
    case eight = "8"
    case nine  = "9"
    
    var value: Double {
        return Double("\(rawValue)")!
    }
}

enum Input {
    case value(Number)
    case opration(Operation)
}

class Calculator {
    
    var data = [Input]()
    
    func run(input: String) -> Double {
        print(input)
        inputData(input: input)
        changeData()
        return ouputData()
    }
    
    /// 把输入的数据解析成运算数据
    func inputData(input: String) {
        for c in input.characters {
            if let num = Number(rawValue: c) {
                data.append(Input.value(num))
            }
            
            if let ope = Operation(rawValue: c) {
                data.append(Input.opration(ope))
            }
        }
    }
    
    /// 把中缀表达式变成后缀表达式
    func changeData() {
        var oper = [Operation]()
        var expr = [Input]()
        var top: Operation!
        for input in data {
            switch input {
            case .value:
                expr.append(input)
            case .opration(let op):
                if oper.isEmpty {
                    oper.append(op)
                    break
                }
                
                top = oper.removeLast()
                while top != nil {
                    if top < op {
                        oper.append(top)
                        oper.append(op)
                        top = nil
                        continue
                    }
                    
                    expr.append(Input.opration(top))
                    if oper.isEmpty {
                        oper.append(op)
                        top = nil
                        continue
                    }
                    
                    top = oper.removeLast()
                }
            }
        }
        for op in oper.reversed() {
            expr.append(Input.opration(op))
        }
        data = expr
        
        
        for e in expr {
            switch e {
            case .value(let num):
                print(num.rawValue, separator: "", terminator: "")
            case .opration(let op):
                print(op.rawValue, separator: "", terminator: "")
            }
        }
        print("")
    }
    
    func ouputData() -> Double {
        var numbers = [Double]()
        for input in data {
            switch input {
            case .value(let num):
                numbers.append(num.value)
            case .opration(let oper):
                let r = numbers.isEmpty ? 0 : numbers.removeLast()
                let l = numbers.isEmpty ? 0 : numbers.removeLast()
                numbers.append(oper[l, r])
            }
        }
        print(numbers)
        return numbers.last ?? 0;
    }
}

let cal = Calculator()
print(cal.run(input: "345*+63/2*+"))
```


