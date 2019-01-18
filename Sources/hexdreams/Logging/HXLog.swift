// hexdreamsCocoa
// HXLog.swift
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

public class HXLog {
    
    public enum Level : Int {
        case trace
        case debug
        case info
        case warn
        case error
        case fatal
        
        public static func from(string str:String) -> Level? {
            if str == "TRACE" {
                return .trace
            } else if str == "DEBUG" {
                return .debug
            } else if str == "INFO" {
                return .info
            } else if str == "WARN" {
                return .warn
            } else if str == "ERROR" {
                return .error
            } else if str == "FATAL" {
                return .fatal
            }
            return nil
        }
        
        public var stringValue:String {
            switch self {
            case .trace:
                return "TRACE"
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .warn:
                return "WARN"
            case .error:
                return "ERROR"
            case .fatal:
                return "FATAL"
            }
        }
    }
    
    let timestamp:Date
    let threadIdentifier:String
    let threadName:String?

    let level:Level
    let function:String
    let file:String
    let line:Int
    let callStackReturnAddresses:[NSNumber]
    
    let callingType:String?
    let callingInstance:String?
    
    let message:String?
    let variables:[String:Any?]?
    let error:String?
    let messageTime:TimeInterval?
    let measureTime:TimeInterval?
    
    // "contextVariables"
    let threadVariables:[String:Any?]?
    let typeVariables:[String:Any?]?
    let instanceVariables:[String:Any?]?

    init(
        timestamp:Date,
        threadIdentifier:String, threadName:String?,
        level:Level,
        function:String, file:String, line:Int,
        callStackReturnAddresses:[NSNumber],
        callingType:String? = nil, callingInstance:String? = nil,
        message:String? = nil, variables:[String:Any?]? = nil, error:Error? = nil,
        messageTime:TimeInterval? = nil, measureTime:TimeInterval? = nil,
        threadVariables:[String:Any?]?, typeVariables:[String:Any?]?, instanceVariables:[String:Any?]?
        )
    {
        self.timestamp = timestamp
        self.threadIdentifier = threadIdentifier
        self.threadName = threadName

        self.level = level
        self.function = function
        self.file = file
        self.line = line
        self.callStackReturnAddresses = callStackReturnAddresses
        
        self.callingType = callingType
        self.callingInstance = callingInstance
        
        self.message = message
        self.variables = variables
        self.error = error?.consoleDescription
        self.messageTime = messageTime
        self.measureTime = measureTime

        self.threadVariables = threadVariables
        self.typeVariables = typeVariables
        self.instanceVariables = instanceVariables
    }
    
    init?(propertyList dict:NSDictionary) {
        guard
            let timestampString = dict["timestamp"] as? String,
            let timestamp = HXLog.dateFromTimestampString(timestampString),
            let threadIdentifier = dict["threadIdentifier"] as? String,
            
            let levelString = dict["level"] as? String,
            let level = Level.from(string:levelString),
            let function = dict["function"] as? String,
            let file = dict["file"] as? String,
            let line = dict["line"] as? NSNumber,
            let callStackReturnAddresses = dict["callStackReturnAddresses"] as? [NSNumber]
            
        
            else {
            return nil
        }
        self.timestamp = timestamp
        self.threadIdentifier = threadIdentifier
        self.threadName = dict["threadName"] as? String
        
        self.level = level
        self.function = function
        self.file = file
        self.line = line.intValue
        self.callStackReturnAddresses = callStackReturnAddresses
        
        self.callingType = dict["callingType"] as? String
        self.callingInstance = dict["callingInstance"] as? String
        
        self.message = dict["message"] as? String
        self.variables = dict["variables"] as? [String:Any?]
        self.error = dict["error"] as? String
        self.messageTime = (dict["messageTime"] as? NSNumber).flatMap {$0.doubleValue / 1E9}
        self.measureTime = (dict["measureTime"] as? NSNumber).flatMap {$0.doubleValue / 1E9}
        
        self.threadVariables = dict["threadVariables"] as? [String:Any?]
        self.typeVariables = dict["typeVariables"] as? [String:Any?]
        self.instanceVariables = dict["instanceVariables"] as? [String:Any?]
    }
    
    var propertyList:[String:Any?] {
        let dict:[String:Any?] = [
            "timestamp"               : self.timestampString,
            "threadIdentifier"        : self.threadIdentifier,
            "threadName"              : self.threadName,
            
            "level"                   : self.level,
            "function"                : self.function,
            "file"                    : self.file,
            "line"                    : self.line,
            "callStackReturnAddresses": self.callStackReturnAddresses,
            
            "callingType"             : self.callingType,
            "callingInstance"         : self.callingInstance,
            
            "message"                 : self.message,
            "variables"               : self.variables,
            "error"                   : self.error,
            "messageTime"             : self.messageTime.flatMap{$0 * 1E9},
            "measureTime"             : self.measureTime.flatMap{$0 * 1E9},
            
            "threadVariables"         : self.threadVariables,
            "typeVariables"           : self.typeVariables,
            "instanceVariables"       : self.instanceVariables
        ]
        
        return hxpropertyList(dict:dict)
    }
    
    public var timestampString:String {
        return self.timestampStringFromDate(self.timestamp)
    }
    
    public var threadString:String {
        if let name = self.threadName,
            name.count > 0 {
            return name
        }
        return self.threadIdentifier
    }
    
    public var codeLocationString:String {
        let file = self.file.hxlastPathComponent.hxexcluding(suffix:".swift")
        return "\(self.callingType ?? "").\(self.function)(\(file):\(self.line))"
    }
    
    public var variableCount:Int {
        var count = 0
        
        if let vars = self.threadVariables {
            count += vars.count
        }
        if let vars = self.typeVariables {
            count += vars.count
        }
        if let vars = self.instanceVariables {
            count += vars.count
        }
        if let vars = self.variables {
            count += vars.count
        }
        return count
    }
    
    private func timestampStringFromDate(_ date:Date) -> String {
        let ns = CALENDAR.component(.nanosecond, from:date)
        var us = ns / 1000
        let ms = us / 1000
        
        var mspadding:String
        if ms < 10 {
            mspadding = "00"
        } else if ms < 100 {
            mspadding = "0"
        } else {
            mspadding = ""
        }
        
        us = us % 1000
        var uspadding:String
        if us < 10 {
            uspadding = "00"
        } else if us < 100 {
            uspadding = "0"
        } else {
            uspadding = ""
        }
        
        return "\(DATE_FORMATTER.string(from:self.timestamp)).\(mspadding)\(ms).\(uspadding)\(us)"
    }
    
    static private func dateFromTimestampString(_ str:String) -> Date? {
        let components = str.split(separator:".")
        let dateString = String(components[0])
        let msString = String(components[1])
        let usString = String(components[2])
        
        guard let intermediate = DATE_FORMATTER.date(from:dateString),
            let ms = Int(msString),
            let us = Int(usString) else {
                return nil
        }
        var dateComponents = CALENDAR.dateComponents([.year, .month, .day, .hour, .minute, .second], from:intermediate)
        let ns = ms * 1000000 + us * 1000
        dateComponents.nanosecond = ns
        let date = CALENDAR.date(from:dateComponents)
        return date
    }
}
