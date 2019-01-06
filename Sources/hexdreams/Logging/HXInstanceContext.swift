//
//  HXInstanceLogger.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 1/2/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Foundation

public class HXInstanceContext {
    
    static private let serialize = DispatchQueue(label:"HXInstanceLogger", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)

    static private var contextsByInstance = [UnsafeMutableRawPointer:HXInstanceContext]()
    
    static func context(for instance:AnyObject) -> HXInstanceContext {
        return serialize.sync {
            let pointer = Unmanaged.passUnretained(instance).toOpaque()
            if let context = contextsByInstance[pointer] {
                return context
            }
            let context = HXInstanceContext(instance:instance)
            contextsByInstance[pointer] = context
            return context
        }
    }
    
    weak var instance:AnyObject?
    private var variables:[String:Any?]?
    private var keyPaths:[String:AnyKeyPath]?

    init(instance:AnyObject) {
        self.instance = instance
    }
    
    public func addVariable(name:String, value:Any?) {
        if self.variables == nil {
            self.variables = [String:Any?]()
        }
        self.variables?[name] = value
    }
    
    public func addKeyPath(name:String, value:AnyKeyPath) {
        if self.keyPaths == nil {
            self.keyPaths = [String:AnyKeyPath]()
        }
        self.keyPaths?[name] = value
    }
    
}
