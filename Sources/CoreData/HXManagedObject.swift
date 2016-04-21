// hexdreamsCocoa
// HXManagedObject.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData

public class HXManagedObject : NSManagedObject {

    public required override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public func update(dict :[String:AnyObject]) -> Bool {
        return true;
    }

}
