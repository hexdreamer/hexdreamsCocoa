// hexdreamsCocoa
// DispatchQueueExtensions.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public extension DispatchQueue {
        
    @inlinable func hxAsync(_ block:@escaping ()throws->Void, hxCatch:@escaping (Error)->Void) {
        self.async {
            do {
                try block()
            } catch {
                hxCatch(error)
            }
        }
    }
    
}
