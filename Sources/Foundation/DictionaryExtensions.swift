//
//  DictionaryExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/5/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

private var _jsonDateFormatter:DateFormatter = Date.rfc3339Formatter

public extension Dictionary {
    
    subscript(jsonObject key:Key) -> AnyObject? {
        guard let val = self[key] else {
            return nil
        }
        if val is NSNull {
            return nil
        }
        return val as AnyObject
    }
    
    subscript(jsonString key:Key) -> String? {
        guard let val = self[jsonObject:key] else {
            return nil
        }
        if let coerced = val as? String {
            return coerced
        }
        fatalError("Could not coerce \(val) to String")
    }
    
    subscript(jsonIntegerNumber key:Key) -> NSNumber? {
        guard let val = self[jsonObject:key] else {
            return nil
        }
        if let coerced = val as? String,
            let parsed = Int(coerced) {
            return NSNumber(value:parsed)
        } else if let coerced = val as? NSNumber {
            return NSNumber(value:coerced.intValue)
        }
        fatalError("Could not coerce \(val) to Integer NSNumber")
    }
    
    subscript(jsonFloatNumber key:Key) -> NSNumber? {
        guard let val = self[jsonObject:key] else {
            return nil
        }
        if let coerced = val as? String,
            let parsed = Float(coerced) {
            return NSNumber(value:parsed)
        } else if let coerced = val as? NSNumber {
            return NSNumber(value:coerced.floatValue)
        }
        fatalError("Could not coerce \(val) to Float NSNumber")
    }
    
    subscript(jsonBoolNumber key:Key) -> NSNumber? {
        guard let val = self[jsonObject:key] else {
            return nil
        }
        if let coerced = val as? String {
            if coerced == "y" || coerced == "Y" {
                return NSNumber(value:true)
            }
            if coerced == "n" || coerced == "N" {
                return NSNumber(value:false)
            }
        } else if let coerced = val as? NSNumber {
            return NSNumber(value:coerced.boolValue)
        }
        fatalError("Could not coerce \(val) to Bool NSNumber")
    }
    
    static var jsonDateFormatter:DateFormatter {
        get {return _jsonDateFormatter}
        set {_jsonDateFormatter = newValue}
    }
    
    subscript(jsonDate key:Key) -> Date? {
        guard let val = self[jsonObject:key] else {
            return nil
        }
        if let coerced = val as? String {
            return _jsonDateFormatter.date(from:coerced)
        }
        fatalError("Could not coerce \(val) to Date")
    }
}
