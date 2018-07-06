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
        
    open func takeValuesFrom(_ dict :[String:AnyObject]) {
        fatalError("not implemented")
    }

}
