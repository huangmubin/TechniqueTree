//
//  Tools.swift
//  SwiftLanguage
//
//  Created by 黄穆斌 on 16/10/16.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

public class Tools {
    
    // 二进制转换: IntegerType 转换成为 String
    public class func binary<T: Integer>(int: T) -> String {
        var bit: Int
        var binary: String
        
        switch int.self {
        case is Int:
            bit = String(Int.max, radix: 2).characters.count
            binary = String(int as! Int, radix: 2)
        case is Int8:
            bit = String(Int8.max, radix: 2).characters.count
            binary = String(int as! Int8, radix: 2)
        case is Int16:
            bit = String(Int16.max, radix: 2).characters.count
            binary = String(int as! Int16, radix: 2)
        case is Int32:
            bit = String(Int32.max, radix: 2).characters.count
            binary = String(int as! Int32, radix: 2)
        case is Int64:
            bit = String(Int64.max, radix: 2).characters.count
            binary = String(int as! Int64, radix: 2)
        case is UInt:
            bit = String(UInt.max, radix: 2).characters.count
            binary = String(int as! UInt, radix: 2)
        case is UInt8:
            bit = String(UInt8.max, radix: 2).characters.count
            binary = String(int as! UInt8, radix: 2)
        case is UInt16:
            bit = String(UInt16.max, radix: 2).characters.count
            binary = String(int as! UInt16, radix: 2)
        case is UInt32:
            bit = String(UInt32.max, radix: 2).characters.count
            binary = String(int as! UInt32, radix: 2)
        case is UInt64:
            bit = String(UInt64.max, radix: 2).characters.count
            binary = String(int as! UInt64, radix: 2)
        default:
            return ""
        }
        var prefix = ""
        for _ in 0 ..< bit - binary.characters.count {
            prefix += "0"
        }
        return prefix + binary
    }
    
    // 二进制转换: String 转成为 Int
    public class func binary(ob: String) -> Int {
        var value = 0
        for (i,c) in ob.characters.enumerated() {
            if c == "1" {
                value = value ^ (1 << (ob.characters.count - i - 1))
            } else if c == "0" {
                continue
            } else {
                return 0
            }
        }
        return value
    }
    
}
