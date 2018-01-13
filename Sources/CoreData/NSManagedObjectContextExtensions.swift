// hexdreamsCocoa
// NSManagedObjectContextExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

public extension NSManagedObjectContext {

    public func fetch<T:NSManagedObject> (
        entity:T.Type,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false
        )
        -> [T]
    {
        do {
            guard let entity = NSEntityDescription.entityForClass(entityClass: T.self, inManagedObjectContext: self),
                let entityName = entity.name else {
                    fatalError()
            }
            let request = NSFetchRequest<T>(entityName:entityName)
            request.predicate = predicate
            if let sortString = sortString {
                try request.sortDescriptors = NSSortDescriptor.sortDescriptorsFrom(string: sortString)
            }
            request.returnsObjectsAsFaults = returnFaults
            let results = try self.fetch(request)
            return results
        } catch {
            fatalError()
        }
    }
    
    public func fetch<T:NSManagedObject> (
        entity:T.Type,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false,
        completion            :@escaping (NSAsynchronousFetchResult<T>)->Void
        )
    {
        do {
            guard let entity = NSEntityDescription.entityForClass(entityClass: T.self, inManagedObjectContext: self),
                let entityName = entity.name else {
                    fatalError()
            }
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            if let sortString = sortString {
                try request.sortDescriptors = NSSortDescriptor.sortDescriptorsFrom(string: sortString)
            }
            request.returnsObjectsAsFaults = returnFaults
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest:request, completionBlock:completion)
            try self.execute(asyncRequest)
        } catch {
            fatalError()
        }
    }
    
    // Add this one so we can do trailing closures
    public func fetch<T:NSManagedObject> (
        entity:T.Type,
        completionBlock:@escaping (NSAsynchronousFetchResult<T>)->Void
        )
    {
        self.fetch(entity:entity, predicate:nil, sortString:nil, returnFaults:false, completion:completionBlock)
    }
    
}
