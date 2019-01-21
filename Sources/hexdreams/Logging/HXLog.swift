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
    
    public let timestamp:HXTimestamp
    public let threadIdentifier:String
    public let threadName:String?

    public let level:Level
    public let function:String
    public let file:String
    public let line:Int
    public let callStackReturnAddresses:[NSNumber]
    
    public let callingType:String?
    public let callingInstance:String?
    
    public let message:String?
    public let variables:[String:Any?]?
    public let error:String?
    public let messageTime:TimeInterval?
    public let measureTime:TimeInterval?
    
    // "contextVariables"
    public let threadVariables:[String:Any?]?
    public let typeVariables:[String:Any?]?
    public let instanceVariables:[String:Any?]?

    public init(
        timestamp:HXTimestamp,
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
        self.error = error?.hxconsoleDescription
        self.messageTime = messageTime
        self.measureTime = measureTime

        self.threadVariables = threadVariables
        self.typeVariables = typeVariables
        self.instanceVariables = instanceVariables
    }
    
    public init?(propertyList dict:NSDictionary) {
        guard
            let timestampString = dict["timestamp"] as? String,
            let timestamp = HXTimestamp(string:timestampString),
            let threadIdentifier = dict["threadIdentifier"] as? String,
            
            let levelString = dict["level"] as? String,
            let level = Level.from(string:levelString),
            let function = dict["function"] as? String,
            let file = dict["file"] as? String,
            let line = dict["line"] as? NSNumber,
            let callStackReturnAddresses = dict["callStackReturnAddresses"] as? [NSNumber]
            else
        { return nil }
        
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
            "timestamp"               : self.timestamp.initString,
            "threadIdentifier"        : self.threadIdentifier,
            "threadName"              : self.threadName,
            
            "level"                   : self.level.stringValue,
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

}
