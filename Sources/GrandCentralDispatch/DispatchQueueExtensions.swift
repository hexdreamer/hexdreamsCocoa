// hexdreamsCocoa
// DispatchQueueExtensions.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public extension DispatchQueue {
    
    @inlinable public func hxSync<T>(_ block:()throws->T) throws -> T {
        var blockError:Error? = nil
        var retVal:T? = nil
        
        self.sync {
            do {
                retVal = try block()
            } catch {
                blockError = error
            }
        }
        
        if let error = blockError {
            throw error
        }
        
        if let val = retVal {
            return val
        }
        
        fatalError("executed block returns nil. This should never happen")
    }
    
    @inlinable public func hxAsync(_ block:@escaping ()throws->Void, hxCatch:@escaping (Error)->Void) {
        self.async {
            do {
                try block()
            } catch {
                hxCatch(error)
            }
        }
    }
    
}
