//
//  NSDateExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 12/2/16.
//  Copyright © 2016 hexdreams. All rights reserved.
//

import Foundation

public extension Date {
    
    private static let defaultCalendar = Date._createDefaultCalendar()
    private static func _createDefaultCalendar() -> Calendar {
        var cal = Calendar(identifier:.gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    static let GMT = Date._createGMTTimeZone()
    private static func _createGMTTimeZone() -> TimeZone {
        guard let TimeZone = TimeZone(abbreviation:"GMT") else {
            fatalError("Could not create GMT time zone")
        }
        return TimeZone
    }

    static func GMTFormatter(timeZone:TimeZone, showTimeZone:Bool) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        if showTimeZone {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        formatter.timeZone = timeZone
        return formatter
    }
    
    static func rfc3339Formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        formatter.timeZone = TimeZone(abbreviation:"GMT")
        formatter.locale = Locale(identifier:"en_US_POSIX")
        return formatter
    }
    
    // MARK: Creating New Dates
    static func dateWith(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int, timeZone:TimeZone) -> Date? {
        var cal = Calendar(identifier:.gregorian)
        cal.timeZone = timeZone
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return cal.date(from: components)
    }
    
    // MARK: Deriving New Dates
    func dateByAdding(years:Int, months:Int, days:Int, hours:Int, minutes:Int, seconds:Int) throws -> Date? {
        let cal = Calendar(identifier:.gregorian)
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from:self)
        
        let addInts = { (a:Int?, b:Int) -> Int in
            guard let a = a else {
                throw HXErrors.invalidArgument(.info(self,"Unexpected error: date component should not be empty"))
            }
            return a + b
        }
        
        try components.year = addInts(components.year, years)
        try components.month = addInts(components.month, months)
        try components.day = addInts(components.day, days)
        try components.hour = addInts(components.hour, hours)
        try components.minute = addInts(components.minute, minutes)
        try components.second = addInts(components.second, seconds)
        return cal.date(from: components)
    }
    
    func beginningOfDay(timeZone:TimeZone) -> Date {
        var cal = Calendar(identifier:.gregorian)
        cal.timeZone = timeZone
        let components = cal.dateComponents([.year, .month, .day], from:self)
        guard let beginningOfDay = cal.date(from:components) else {
            fatalError("Could not generate beginning of date \(self)")
        }
        return beginningOfDay
    }
    
    func endOfDay(timeZone:TimeZone) -> Date {
        var cal = Calendar(identifier:.gregorian)
        cal.timeZone = timeZone
        var components = cal.dateComponents([.year, .month, .day], from:self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        guard let endOfDay = cal.date(from:components) else {
            fatalError("Could not generate end of date \(self)")
        }
        return endOfDay
    }
            
    // MARK: Comparing Dates
    func equalTo(other :Date) -> Bool  {
        return self.compare(other) == .orderedSame
    }
    
    func greaterThan(other :Date) -> Bool  {
        return self.compare(other) == .orderedDescending
    }

    func greaterThanOrEqualTo(other :Date) -> Bool  {
        return self.compare(other) != .orderedAscending
    }

    func lessThan(other :Date) -> Bool  {
        return self.compare(other) == .orderedAscending
    }

    func lessThanOrEqualTo(other :Date) -> Bool  {
        return self.compare(other) != .orderedDescending
    }

    func sameDayAs(other :Date) -> Bool {
        let me = Date.defaultCalendar.dateComponents([.year,.month,.day], from:self)
        let yu = Date.defaultCalendar.dateComponents([.year,.month,.day], from:other)
        return (me.year == yu.year && me.month == yu.month && me.day == yu.day);
    }

}
