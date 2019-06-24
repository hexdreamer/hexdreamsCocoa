// hexdreamsCocoa
// HXPropertyList.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

// Should probably turn this into a protocol adoptable by any object, with extensions for arrays and dictionaries.

import Foundation

public func hxpropertyList(_ obj:Any?) -> Any? {
    guard let obj = obj else {
        return NSNull()
    }
    
    if let s = obj as? String {
        return s
    } else if let substr = obj as? Substring {
        return String(substr)
    } else if let b = obj as? Bool {
        return b
    } else if let i = obj as? Int {
        return i
    } else if let f = obj as? Float {
        return f
    } else if let d = obj as? Double {
        return d
    } else if let n = obj as? NSNumber {
        return n
    } else if let error = obj as? Error {
        return error.hxconsoleDescription
    } else if let dict = obj as? [String:Any?] {
        return hxpropertyList(dict:dict)
    } else if let arr = obj as? [Any?] {
        return hxpropertyList(array:arr)
    } else {
        return "\(obj)"
    }
}

public func hxpropertyList(dict:[String:Any?]) -> [String:Any?] {
    var result = [String:Any?]()
    
    for (key,value) in dict {
        result[key] = hxpropertyList(value)
    }
    return result
}

public func hxpropertyList(array:[Any?]) -> [Any?] {
    return array.map {hxpropertyList($0)}
}
