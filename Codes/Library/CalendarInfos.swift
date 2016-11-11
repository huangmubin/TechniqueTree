//
//  CalendarInfos.swift
//  Calendar
//
//  Created by 黄穆斌 on 16/11/11.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

import Foundation

// MARK: Calendar Infos

class CalendarInfos {
    
    // MARK: Date
    
    var calendar: Calendar
    var date: Date
    
    // MARK: Init
    
    init(calendar: Calendar = Calendar.current, date: Date = Date()) {
        self.calendar = calendar
        self.date = date
    }
    
    init(calendar: Calendar = Calendar.current, date: TimeInterval) {
        self.calendar = calendar
        self.date = Date(timeIntervalSince1970: date)
    }
    
    // MARK: Infos
    
    var year: Int {
        return calendar.component(Calendar.Component.year, from: date)
    }
    var month: Int {
        return calendar.component(Calendar.Component.month, from: date)
    }
    var day: Int {
        return calendar.component(Calendar.Component.day, from: date)
    }
    /// Sunday is 0
    var weekday: Int {
        return calendar.component(Calendar.Component.weekday, from: date) - 1
    }
    var week: CalendarInfos.Week {
        return CalendarInfos.Week(rawValue: weekday)!
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
    
    // MARK: Count
    
    var daysInMonth: Int {
        return CalendarInfos.days(inMonth: month, inYear: year)
    }
    
    var daysInYear: Int {
        return CalendarInfos.days(inYear: year)
    }
    
}

// MARK: - Class Methods

extension CalendarInfos {
    
    // MARK: Days
    
    /// month = 0 ~ 11
    class func days(inMonth: Int, inYear: Int) -> Int {
        let total = inYear * 12 + inMonth
        let year = total / 12
        let month = total % 12 + 1
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

// MARK: - CalendarInfos.Week

extension CalendarInfos {
    
    enum Week: Int {
        case Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        
        static func day(_ day: Int) -> Week {
            return Week(rawValue: abs(day % 7))!
        }
        
        init?(day: Int) {
            self.init(rawValue: abs(day % 7))
        }
    }
    
}
