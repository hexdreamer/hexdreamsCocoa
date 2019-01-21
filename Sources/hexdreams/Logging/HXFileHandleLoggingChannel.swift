// hexdreamsCocoa
// HXFileLoggingChannel.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXFileHandleLoggingChannel : HXLoggingChannel {
    
    private let serialize = DispatchQueue(label:"HXFileHandleLoggingChannel", qos:.background, attributes:[], autoreleaseFrequency:.workItem, target:nil)

    let filehandle:FileHandle
    var logs = [HXLog]()
    var flushEnqueued = false
    
    init(filehandle:FileHandle) {
        self.filehandle = filehandle
    }
    
    public func log(_ log:HXLog) {
        self.serialize.async {
            self.logs.append(log)
            if !self.flushEnqueued {
                self.serialize.async {
                    self.flushLogs()
                    self.flushEnqueued = false
                }
                self.flushEnqueued = true
            }
        }
    }

    public func addLogs(_ logs:[HXLog]) {
        self.serialize.async {
            self.logs.append(contentsOf:logs)
        }
    }

    func flushLogs() {
        //print("## Flushing \(self.logs.count) logs")
        for log in self.logs {
            let logString = self.render(log)
            guard let data = logString.data(using:.utf8) else {
                continue
            }
            filehandle.write(data)
        }
        self.logs.removeAll()
    }
    
    func render(_ log:HXLog) -> String {
        
        let messageString:String
        if let messageTime = log.messageTime,
            let message = log.message {
            messageString = " (\(HXTimeIntervalFormatter.string(from:messageTime)))\(message)"
        } else if let messageTime = log.messageTime {
            messageString = " (\(HXTimeIntervalFormatter.string(from:messageTime)))"
        } else if let message = log.message {
            messageString = " \(message)"
        } else {
            messageString = ""
        }
        
        let measureString:String
        if let measureTime = log.measureTime {
            measureString = " (\(HXTimeIntervalFormatter.string(from:measureTime)))"
        } else {
            measureString = ""
        }
        
        let variableCount = log.variableCount
        let variablesString:String
        if messageString.count == 0 && variableCount == 1 {
            variablesString = " \(self.renderVariables(log))"
        } else if variableCount > 0 {
            variablesString = "\n\(self.renderVariables(log))"
        } else {
            variablesString = ""
        }
        
        return "\(log.timestamp.hxconsoleDescription) \(log.level.stringValue) [\(log.threadString)] \(log.codeLocationString)\(messageString)\(measureString)\(variablesString)\n"
    }
    
    func renderVariables(_ log:HXLog) -> String {
        let errorDict:[String:Any?]? = (log.error != nil) ? ["error":log.error] : nil
        let dicts:[[String:Any?]] = [log.threadVariables, log.typeVariables, log.instanceVariables, log.variables, errorDict].compactMap {$0}
        
        if dicts.count == 0 {
            return ""
        }
        
        if dicts.count == 1 && dicts[0].count == 1 {
            for (key,value) in dicts[0] {
                return "\(key): \(value ?? "nil")"
            }
        }
        
        var width = 0
        for dict in dicts {
            for (key,_) in dict {
                width = max(width, key.count)
            }
        }
        width += 4
        
        var s = ""
        var first = true
        for dict in dicts {
            for (key,value) in dict {
                if !first {
                    s += "\n"
                }
                first = false
                s += "\(key.hxpad(width:width)): \(value ?? "nil")"
            }
        }
        return s
    }
}
