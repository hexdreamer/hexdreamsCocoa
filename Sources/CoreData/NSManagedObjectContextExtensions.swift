// hexdreamsCocoa
// NSManagedObjectContextExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

public extension NSManagedObjectContext {
    
    public func fetch(
        entityName entityName :String,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false)
        throws -> [AnyObject]? {

        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        if let sortString = sortString {
            try request.sortDescriptors = NSSortDescriptor.sortDescriptorsFromString(sortString)
        }
        request.returnsObjectsAsFaults = returnFaults
        let results = try self.executeFetchRequest(request)
        return results
    }
    
}
