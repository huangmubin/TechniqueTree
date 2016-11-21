//
//  CalendarInfos.swift
//  Calendar
//
//  Created by 黄穆斌 on 16/11/11.
//  Copyright © 2016年 Myron. All rights reserved.
//

import Foundation

// MARK: Calendar Infos

class CalendarInfo {
    
    // MARK: Value
    
    var calendar: Calendar
    var date: Date
    
    // MARK: Init
    
    init(identifier: Calendar.Identifier = Calendar.current.identifier, date: Date = Date()) {
        self.calendar = Calendar(identifier: identifier)
        self.date = date
    }
    
    init(identifier: Calendar.Identifier = Calendar.current.identifier, date: TimeInterval) {
        self.calendar = Calendar(identifier: identifier)
        self.date = Date(timeIntervalSince1970: date)
    }
    
    // MARK: Date
    
    var year: Int {
        return calendar.component(Calendar.Component.year, from: date)
    }
    var month: Int {
        return calendar.component(Calendar.Component.month, from: date)
    }
    var day: Int {
        return calendar.component(Calendar.Component.day, from: date)
    }
    /// Sunday is 1
    var weekday: Int {
        return calendar.component(Calendar.Component.weekday, from: date) - 1
    }
    var week: CalendarInfo.Week {
        return CalendarInfo.Week(rawValue: weekday)!
    }
    
    var hour: Int {
        return calendar.component(Calendar.Component.hour, from: date)
    }
    var minute: Int {
        return calendar.component(Calendar.Component.minute, from: date)
    }
    var second: Int {
        return calendar.component(Calendar.Component.second, from: date)
    }
    var weekOfMonth: Int {
        return calendar.component(Calendar.Component.weekOfMonth, from: date)
    }
    var weekOfYear: Int {
        return calendar.component(Calendar.Component.weekOfYear, from: date)
    }
    
    // MARK: Counts
    
    var daysInMonth: Int {
        return CalendarInfo.days(inMonth: month, inYear: year)
    }
    
    var daysInYear: Int {
        return CalendarInfo.days(inYear: year)
    }
    
    // MARK: First
    
    func firstDayInYear() -> Date? {
        return calendar.date(from: calendar.dateComponents([.year], from: date))
    }
    
    func firstDayInMonth() -> Date? {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))
    }
    
    func firstDayInWeek() -> Date? {
        var weekFirst: Date = Date()
        var interval: TimeInterval = 0
        if calendar.dateInterval(of: .weekOfYear, start: &weekFirst, interval: &interval, for: date) {
            return weekFirst
        } else {
            return nil
        }
    }
    
    func firstTimeInDay() -> Date? {
        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date))
    }
    
    // MARK: Advand
    
    func adding(time: TimeInterval) -> Date {
        return date.addingTimeInterval(time)
    }
    
    func offset(time: TimeInterval) -> CalendarInfo {
        let new = date.addingTimeInterval(time)
        return CalendarInfo(identifier: calendar.identifier, date: new)
    }
    
}

// MARK: - Class Methods

extension CalendarInfo {
    
    // MARK: Days
    
    /// month = 0 ~ 11
    class func days(inMonth: Int, inYear: Int) -> Int {
        let total = inYear * 12 + inMonth
        let year = total / 12
        let month = total % 12
        switch month {
        case 2:
            return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }
    
    class func days(inYear: Int) -> Int {
        return (inYear % 4 == 0 && inYear % 100 != 0) || (inYear % 400 == 0) ? 366 : 365
    }
    
}

// MARK: - Week and Timestamp enums

extension CalendarInfo {
    
    enum Week: Int {
        case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        
        static func day(_ day: Int) -> Week {
            return Week(rawValue: abs(day % 7))!
        }
        
        init?(day: Int) {
            self.init(rawValue: abs(day % 7))
        }
    }
    
    enum Timestamp: TimeInterval {
        case minute = 60.0
        case hour   = 3600.0
        case day    = 86400.0
        case week   = 604800.0
        
        subscript(offset: Int) -> Double {
            return rawValue * Double(offset)
        }
    }
    
}

// MARK: - Chinese

extension CalendarInfo {
    
    static let Chinese: (
        Era: [String],
        CelestialStems: [String],
        EarthlyBranches: [String],
        Zodiacs: [String],
        Months: [String],
        Days: [String]
    ) = (
        [
            "甲子", "乙丑", "丙寅", "丁卯", "午辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
            "甲戌", "乙亥", "丙子", "丁丑", "午寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
            "甲申", "乙酉", "丙戌", "丁亥", "午子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
            "甲午", "乙未", "丙申", "丁酉", "午戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
            "甲辰", "乙巳", "丙午", "丁未", "午申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
            "甲寅", "乙卯", "丙辰", "丁巳", "午午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
        ],
        ["甲", "乙", "丙", "丁", "午", "己", "庚", "辛", "壬", "癸"],
        ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"],
        ["鼠", "牛", "虎", "兔", "龙", "色", "马", "羊", "猴", "鸡", "狗", "猪"],
        ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"],
        [
            "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
        ]
    )
    
    var chineseYear: String {
        return CalendarInfo.Chinese.Era[(year - 1) % 60]
    }
    var chineseZodiac: String {
        return CalendarInfo.Chinese.Zodiacs[(year - 1) % 12]
    }
    var chineseMonth: String {
        return CalendarInfo.Chinese.Months[month - 1]
    }
    var chineseDay: String {
        return CalendarInfo.Chinese.Days[day - 1]
    }
}
