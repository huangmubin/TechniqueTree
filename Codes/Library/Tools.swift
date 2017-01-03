//
//  Tools.swift
//  SwiftLanguage
//
//  Created by 黄穆斌 on 16/10/16.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

public class Tools {
    
    // MARK: - 进制转换工具
    
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
    
    // MARK: - 日期获取
    
    public class func day(time: TimeInterval) -> String? {
        let now = Double(Int(Date().timeIntervalSince1970 / 86400) * 86400)
        switch time {
        case now - 172800 ..< now - 86400:
            return "前天"
        case now - 86400 ..< now:
            return "昨天"
        case now ..< now + 86400:
            return "今天"
        case now + 86400 ..< now + 172800:
            return "明天"
        case now + 172800 ..< now + 259200:
            return "后天"
        default:
            return nil
        }
    }
    
    public class func minute(time: TimeInterval) -> String {
        var str = ""
        let min = Int(time) / 60
        if min >= 10 {
            str += "\(min)"
        } else {
            str += "0\(min)"
        }
        
        let sec = Int(time) % 60
        if sec >= 10 {
            str += ":\(sec)"
        } else {
            str += ":0\(sec)"
        }
        return str
    }
    
    // MARK: - Location
    
    public class func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: key)
    }
    
    public class func localized(_ result: Bool, _ key1: String, _ key2: String) -> String {
        if result {
            return NSLocalizedString(key1, comment: key1)
        } else {
            return NSLocalizedString(key2, comment: key2)
        }
    }
    
    
    
    
}

