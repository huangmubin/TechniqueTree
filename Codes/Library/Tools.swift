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
    
    public class func day(time: TimeInterval, format: String? = nil) -> String? {
        let now = Double(Int(Date().timeIntervalSince1970 / 86400) * 86400)
        switch time {
        case now - 172800 ..< now - 86400:
            return NSLocalizedString("Day before yesterday", comment: "Day before yesterday")
        case now - 86400 ..< now:
            return NSLocalizedString("Yesterday", comment: "Yesterday")
        case now ..< now + 86400:
            return NSLocalizedString("Today", comment: "Today")
        case now + 86400 ..< now + 172800:
            return NSLocalizedString("Tomorrow", comment: "Tomorrow")
        case now + 172800 ..< now + 259200:
            return NSLocalizedString("Day after tomorrow", comment: "Day after tomorrow")
        default:
            if let format = format {
                let date = DateFormatter()
                date.dateFormat = format
                return date.string(from: Date(timeIntervalSince1970: time))
            }
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
    
    public class func timezoneOffset() -> Double {
        let zone = TimeZone.current
        let offset = zone.secondsFromGMT(for: Date())
        return Double(offset)
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
    
    // MARK: - Timer Run
    
    public class func runTimer(long: Double, handler: @escaping (Double) -> Void, cancel: (() -> Void)? = nil) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 1), queue: DispatchQueue.main)
        timer.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: DispatchTimeInterval.seconds(1))
        var time = long
        timer.setEventHandler(handler: {
            time -= 1
            if time == 0 {
                timer.cancel()
            } else {
                handler(time)
            }
        })
        if cancel != nil {
            timer.setCancelHandler(handler: {
                cancel?()
            })
        }
        timer.resume()
        return timer
    }
    
    public class func delay(time: TimeInterval, complete: @escaping () -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: time)
            DispatchQueue.main.async {
                complete()
            }
        }
    }
    
}

