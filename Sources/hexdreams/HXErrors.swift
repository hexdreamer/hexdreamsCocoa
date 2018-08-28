//
//  HXErrors.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/24/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//
// 🛑

import Foundation

public enum HXErrors : Error {
    case unimplemented(Info)
    case general(Info)
    case invalidArgument(Info)
    case hxnil(Info)
    case objectNotFound(Info)
    case moreThanOneObjectFound(Info,[Any]) // array of all found
    case internalInconsistency(Info)
    case network(Info)
    case cocoa(Info)
    
    public var name:String {
        let name:String
        
        switch self {
        case .unimplemented:
            name = "unimplemented"
        case .general:
            name = "general"
        case .invalidArgument:
            name = "invalidArgument"
        case .hxnil:
            name = "hxnil"
        case .objectNotFound:
            name = "objectNotFound"
        case .moreThanOneObjectFound:
            name = "moreThanOneObjectFound"
        case .internalInconsistency:
            name = "internalInconsistency"
        case .network:
            name = "network"
        case .cocoa:
            name = "cocoa"
        }
        
        return name
    }
    
    public struct Info {
        var message:String?
        var thrower:Any?
        var causingErrors:[Error]?
        var functionName:StaticString
        var filePath:StaticString
        var lineNumber:Int
        
        public init(thrower:Any?,
                    message:String?,
                    causingErrors:[Error]?,
                    functionName:StaticString,
                    filePath:StaticString,
                    lineNumber:Int) {
            self.thrower = thrower
            self.message = message
            self.causingErrors = causingErrors
            self.functionName = functionName
            self.filePath = filePath
            self.lineNumber = lineNumber
        }
        
        static public func info(_ thrower:Any?,
                                _ message:String?,
                                causingErrors:[Error]? = nil,
                                functionName:StaticString = #function,
                                filePath:StaticString = #file,
                                lineNumber:Int = #line) -> Info {
            return Info(thrower:thrower, message:message, causingErrors:causingErrors, functionName:functionName, filePath:filePath, lineNumber:lineNumber)
        }
        
        public var consoleDescription:String {
            var className:String? = nil
            
            if let thrower = thrower {
                className = String(describing:type(of:thrower))
            }
            
            let fileName = filePath.withUTF8Buffer { (buffer)->String in
                let path = String(decoding:buffer, as:UTF8.self)
                let url = URL.init(fileURLWithPath:path)
                let file = url.lastPathComponent
                return file
            }
            
            var desc:String = ""
            if let className = className {
                desc += "\(className)."
            }
            desc += "\(functionName)(\(fileName):\(lineNumber))"
            if let message = self.message {
                desc += " "
                desc += message
            }
            if let errors = self.causingErrors {
                for error in errors {
                    desc += "\n    Caused by: "
                    desc += error.consoleDescription
                }
            }
            
            return desc
        }
    }
}

public protocol HXErrorHandler:AnyObject {
    var error:Error? {get set}
}

public extension Error {
    public var consoleDescription:String {
        guard let error = self as? HXErrors else {
            return String(describing:self)
        }
        
        let desc:String
        
        switch error {
        case .unimplemented(let info):
            desc = info.consoleDescription
        case .general(let info):
            desc = info.consoleDescription
        case .invalidArgument(let info):
            desc = info.consoleDescription
        case .hxnil(let info):
            desc = info.consoleDescription
        case .objectNotFound(let info):
            desc = info.consoleDescription
        case .moreThanOneObjectFound(let (info,_)):
            desc = info.consoleDescription
        case .internalInconsistency(let info):
            desc = info.consoleDescription
        case .network(let info):
            desc = info.consoleDescription
        case .cocoa(let info):
            desc = info.consoleDescription
        }
        
        return "\(error.name) at \(desc)"
    }
}
