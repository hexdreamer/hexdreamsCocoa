// hexdreamsCocoa
// NSManagedObjectContextExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

public extension NSManagedObjectContext {

    public func pdfetch(
        entityName            :String,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false)
        throws -> [Any] {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        if let sortString = sortString {
            try request.sortDescriptors = NSSortDescriptor.sortDescriptorsFrom(string: sortString)
        }
        request.returnsObjectsAsFaults = returnFaults
        let results = try self.fetch(request)
        return results
    }
    
}
