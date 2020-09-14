//
//  File.swift
//  
//
//  Created by Kenny Leung on 9/13/20.
//

import Foundation

// Pseudo-Generic methods for NSSet, to work more easily with CoreData
// (CoreData's to-many relationships are NSSets)
public extension NSSet {
    
    func hxfirst<T>(
        _ type: T.Type,
        where predicate: (T) throws -> Bool
    ) rethrows -> T?
    {
        for x in self {
            guard let typed = x as? T else {
                HXFetalError("\(x) not of type \(type)")
                continue
            }
            if try predicate(typed) {
                return typed
            }
        }
        return nil
    }
    
    func hxmap<T,R>(
        _ type: T.Type,
        _ transform: (T) throws -> R
    ) rethrows -> [R]
    {
        var results = [R]()
        for x in self {
            guard let typed = x as? T else {
                HXFetalError("\(x) not of type \(type)")
                continue
            }
            results.append(try transform(typed))
        }
        return results
    }
    
}
