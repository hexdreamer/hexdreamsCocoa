// hexdreamsCocoa
// HXTimestamp.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

fileprivate let CALENDAR:Calendar = {
    var calendar = Calendar(identifier:.gregorian)
    calendar.timeZone = Date.GMT
    return calendar
}()

fileprivate let DATE_FORMATTER:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = Date.GMT
    return formatter
}()

public struct HXTimestamp {
    
    var date:Date
    var ns:Int
    
    init() {
        self.init(date:Date())
    }
    
    init(date:Date) {
        let ns = CALENDAR.dateComponents([.nanosecond], from:date).nanosecond ?? {
            hxerror("Could not get nanoseconds from date: \(date)")
            return 0
        }
        self.init(date:date, nanoseconds:ns)
    }
    
    init(date:Date, nanoseconds:Int) {
        self.date = date
        self.ns = nanoseconds
    }
    
    init?(string str:String) {
        let components = str.split(separator:".")
        guard let date = Date.rfc3339Formatter.date(from:String(components[0])),
        let ns = Int(String(components[1])) else {
            hxerror("Could not initialize date from string: \(str)")
            return nil
        }
        self.init(date:date, nanoseconds:ns)
    }
    
    var initString:String {
        return "\(Date.rfc3339Formatter.string(from:self.date)).\(self.ns)"
    }
    
    var hxconsoleDescription:String {
        let baseDescription = DATE_FORMATTER.string(from:self.date)
        let msString = "\(self.ns / 1000)".hxpad(width:6, with:"0")
        return "\(baseDescription).\(msString)"
    }
}
