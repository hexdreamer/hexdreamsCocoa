// hexdreamsCocoa
// HXManagedObject.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData

public class HXManagedObject : NSManagedObject {

    public required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public func takeValuesFrom(_ dict :[String:AnyObject]) -> Bool {
        return true;
    }

}
