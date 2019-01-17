// hexdreamsCocoa
// HXLog.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXLog {
    
    public enum Level {
        case trace
        case debug
        case info
        case warn
        case error
        case fatal
    }

    let timestamp:Date
    let threadIdentifier:UnsafeMutableRawPointer
    let threadName:String?

    let level:Level
    let function:String
    let file:String
    let line:Int
    let callStackReturnAddresses:[NSNumber]
    
    let callingType:String?
    let callingInstance:UnsafeMutableRawPointer?
    
    let message:String?
    let variables:[String:Any?]?
    let error:Error?
    let messageTime:TimeInterval?
    let measureTime:TimeInterval?
    
    // "contextVariables"
    let threadVariables:[String:Any?]?
    let typeVariables:[String:Any?]?
    let instanceVariables:[String:Any?]?

    init(
        timestamp:Date,
        threadIdentifier:UnsafeMutableRawPointer, threadName:String?,
        level:Level,
        function:String, file:String, line:Int,
        callStackReturnAddresses:[NSNumber],
        callingType:String? = nil, callingInstance:UnsafeMutableRawPointer? = nil,
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
        self.error = error
        self.messageTime = messageTime
        self.measureTime = measureTime

        self.threadVariables = threadVariables
        self.typeVariables = typeVariables
        self.instanceVariables = instanceVariables
    }
    
    static let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    public var timestampString:String {
        let ns = Calendar.current.component(.nanosecond, from:self.timestamp)
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

        return "\(HXLog.dateFormatter.string(from:self.timestamp)).\(mspadding)\(ms).\(uspadding)\(us)"
    }
    
    public var levelString:String {
        switch self.level {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return " INFO"
        case .warn:
            return " WARN"
        case .error:
            return "ERROR"
        case .fatal:
            return "FATAL"
        }
    }
    
    public var threadString:String {
        if let name = self.threadName,
            name.count > 0 {
            return name
        }
        return "\(self.threadIdentifier)"
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
        
        /*
        print("Swift:\(dict)\n")
        
        do {
            guard let plist = hxpropertyList(dict) else {
                fatalError()
            }
            let json = try JSONSerialization.data(withJSONObject:plist, options:[.prettyPrinted, .sortedKeys])
            let jsonString = String(data:json, encoding:.utf8)
            print("JSON:\(jsonString ?? "nil")\n")
        } catch {
            print("Error!")
        }
         */
        
        return hxpropertyList(dict:dict)
    }

}
