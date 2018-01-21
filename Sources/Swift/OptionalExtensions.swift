//
//  OptionalExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 1/19/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

// Requires Swift 4.1 or higher - conditional conformances

public extension Optional where Wrapped == Bool {
    public var boolValue:Bool {
        guard let val = self else {
            return false
        }
        return val
    }
}

public extension Optional where Wrapped == NSNumber {
    public var boolValue:Bool {
        guard let val = self else {
            return false
        }
        return val.boolValue
    }
}
