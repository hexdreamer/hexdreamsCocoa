//
//  HXTimeIntervalFormatter.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 1/5/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Foundation

public class HXTimeIntervalFormatter {
    
    static public func string(from time:TimeInterval) -> String {
        if time < 0.000000001 {
            return ""
        } else if time < 0.00000001 {
            return String(format:"%1.2fns", time * 1000000000)
        } else if time < 0.0000001 {
            return String(format:"%2.1fns", time * 1000000000)
        } else if time < 0.000001 {
            return String(format:"%.0fns", time * 1000000000)
        } else if time < 0.00001 {
            return String(format:"%1.2fµs", time * 1000000)
        } else if time < 0.0001 {
            return String(format:"%2.1fµs", time * 1000000)
        } else if time < 0.001 {
            return String(format:"%.0fµs", time * 1000000)
        } else if time < 0.01 {
            return String(format:"%1.2fms", time * 1000)
        } else if time < 0.1 {
            return String(format:"%2.1fms", time * 1000)
        } else if time < 1.0 {
            return String(format:"%.0fms", time * 1000)
        } else if time < 10.0 {
            return String(format:"%1.2fs", time)
        } else if time < 100.0 {
            return String(format:"%2.1fs", time)
        } else {
            return String(format:"%.0fs", time)
        }
    }
    
}
