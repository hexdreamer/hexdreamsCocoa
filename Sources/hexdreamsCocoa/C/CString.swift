// hexdreamsCocoa
// CString.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

extension C {
    
    // Copies data
    // https://stackoverflow.com/questions/27455773/converting-a-c-char-array-to-a-string
    public static func string<T>(_ value:inout T) -> String {
        let capacity = MemoryLayout.size(ofValue:value)
        return withUnsafePointer(to:&value) {
            $0.withMemoryRebound(to:UInt8.self, capacity:capacity) {
                String(cString:$0)
            }
        }
    }
    
}
