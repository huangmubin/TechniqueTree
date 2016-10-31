//
//  Tools.swift
//  SwiftLanguage
//
//  Created by 黄穆斌 on 16/10/16.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

public class Tools {
    
    // MARK: 进制转换工具
    
    /// 进制转换: SignedInteger 转换成为 String
    public class func binary<T: SignedInteger>(_ value: T, long: Int = 8, radix: Int = 2, uppercase: Bool = true) -> String {
        var bite = String(value, radix: radix, uppercase: uppercase)
        if bite.characters.count < long {
        return String(repeating: "0", count: long - bite.characters.count) + bite
        }
        return bite
    }
    
    /// 进制转换: SignedInteger 转换成为 String
    public class func binary<T: UnsignedInteger>(_ value: T, long: Int = 8, radix: Int = 2, uppercase: Bool = true) -> String {
        var bite = String(value, radix: radix, uppercase: uppercase)
        if bite.characters.count < long {
            return String(repeating: "0", count: long - bite.characters.count) + bite
        }
        return bite
    }
    
    // 进制转换: String 转成为 Int
    public class func binary(_ value: String, radix: Int = 2) -> Int {
        return Int(value, radix: radix) ?? 0
    }
    
    // MARK: - 获取随机数
    
    public class func randomInRange(range: Range<Int>) -> Int {
        return  Int(arc4random_uniform(UInt32(range.count))) + range.lowerBound
    }
    
}
