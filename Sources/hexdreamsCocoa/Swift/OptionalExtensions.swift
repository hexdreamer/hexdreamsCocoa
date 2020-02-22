//
//  OptionalExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 1/19/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

// Requires Swift 4.1 or higher - conditional conformances

import Foundation

public extension Optional where Wrapped == Bool {
    var hxboolValue:Bool {
        guard let val = self else {
            return false
        }
        return val
    }
}

public extension Optional where Wrapped == NSNumber {
    var hxboolValue:Bool {
        guard let val = self else {
            return false
        }
        return val.boolValue
    }
}

public extension Optional where Wrapped : StringProtocol {
    func hxisBlank() -> Bool {
        if let x = self {
            return x.hxisBlank()
        } else {
            return true
        }
    }
}
