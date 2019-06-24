//
//  Utilities.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 8/3/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

// Strip down a filename to A-Za-Z0-9 _ - .
// cut down the length to first and last 10 characters, so max would be Supercalif...ocious.png

fileprivate let _allowableCharacters:CharacterSet = {
    let letters = CharacterSet.letters
    let digits = CharacterSet.init(charactersIn:"0123456789.-@")
    let allowable = letters.union(digits)
    return allowable
}()

public func HXSafeFilename(_ orig:String, fixLength:Int) -> String {
    let stripped = orig.compactMap { (char)->Character? in
        for scalar in char.unicodeScalars {
            if !_allowableCharacters.contains(scalar) {
                return nil // block
            }
        }
        return char // block
    }
    
    if stripped.count <= 2 * fixLength {
        return String(stripped)
    }
    
    let prefix = stripped.prefix(fixLength)
    let suffix = stripped.suffix(fixLength)
    var shortened = [Character]()
    shortened.append(contentsOf:prefix)
    shortened.append(".")
    shortened.append(".")
    shortened.append(".")
    shortened.append(contentsOf:suffix)
    return String(shortened)
}
