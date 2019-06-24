// hexdreamsCocoa
// HXTypeContext.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXTypeContext {
    
    static private let serialize = DispatchQueue(label:"HXTypeContext", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    
    static private var contextsByType = [ObjectIdentifier:HXTypeContext]()
    
    static func context(for sometype:Any.Type) -> HXTypeContext {
        return serialize.sync {
            let identifier = ObjectIdentifier(sometype)
            if let logger = contextsByType[identifier] {
                return logger
            }
            let logger = HXTypeContext(type:sometype)
            contextsByType[identifier] = logger
            return logger
        }
    }
    
    let referencedType:Any.Type
    let typeName:String
    var variables:[String:Any?]?
    var keyPaths:[String:AnyKeyPath]?
    
    public init(type:Any.Type) {
        self.referencedType = type
        self.typeName = "\(type)"
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
