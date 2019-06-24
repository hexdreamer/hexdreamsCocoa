// hexdreamsCocoa
// HXThreadContext.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXThreadContext {
    
    static let threadDictionaryKey = "HXThreadLogger"
    
    static func context(for thread:Thread) -> HXThreadContext {
        if let context = thread.threadDictionary[threadDictionaryKey] as? HXThreadContext {
            return context
        }
        let context = HXThreadContext(thread:thread)
        thread.threadDictionary[threadDictionaryKey] = context
        return context
    }

    let threadName:String?
    let threadPointer:UnsafeMutableRawPointer
    var threadVariables:[String:Any?]?
    
    init(thread:Thread) {
        self.threadName = thread.name
        self.threadPointer = Unmanaged.passUnretained(thread).toOpaque()
    }
    
    public func setThreadVariable(key:String, value:Any?) {
        if self.threadVariables == nil {
            self.threadVariables = [String:Any?]()
        }
        self.threadVariables?[key] = value
    }
}
