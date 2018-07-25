// hexdreamsCocoa
// HXManagedObject.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData

open class HXManagedObject : NSManagedObject {

    public override required init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public var moc:NSManagedObjectContext {
        guard let moc = self.managedObjectContext else {
            fatalError("asked for moc on object where moc is nil")
        }
        return moc
    }
    
    open func takeValuesFrom(_ dict :[String:AnyObject]) {
        fatalError("not implemented")
    }

    public func forEach<C:Sequence,E>(
        in     container:C?,
        ofType elementType:E.Type,
        do     body:(E)throws->Void
        ) rethrows
    {
        guard let nncontainer = container else {
            fatalError("To-many relationship in managed object \(self) cannot be nil")
        }
        for i in nncontainer {
            guard let e = i as? E else {
                fatalError("\(nncontainer) should not contain element \(i) of type \(type(of:i))")
            }
            try body(e)
        }
    }
    
    public func first<C:Sequence,E>(
        in     container:C?,
        ofType elementType:E.Type,
        where  predicate:(E)throws->Bool
        ) rethrows
        -> E?
    {
        guard let nncontainer = container else {
            fatalError("To-many relationship in managed object \(self) cannot be nil")
        }
        for i in nncontainer {
            guard let e = i as? E else {
                fatalError("\(nncontainer) should not contain element \(i) of type \(type(of:i))")
            }
            if try predicate(e) {
                return e
            }
        }
        return nil
    }
    
    public func cast<C:Sequence,E>(
        _ container:C?,
        toType elementType:E.Type
        ) -> [E]
    {
        guard let nncontainer = container else {
            fatalError("To-many relationship in managed object \(self) cannot be nil")
        }

        var result = [E]()
        for i in nncontainer {
            guard let e = i as? E else {
                fatalError("\(nncontainer) should not contain element \(i) of type \(type(of:i))")
            }
            result.append(e)
        }
        return result
    }
    
    public func convert<E:RawRepresentable>(_ attribute:E.RawValue?, toEnum:E.Type) -> E? {
        guard let nnattribute = attribute else {
            return nil
        }
        guard let converted = E.init(rawValue:nnattribute) else {
            fatalError("Could not convert \(nnattribute) to enum \(E.self)")
        }
        return converted
    }


}
