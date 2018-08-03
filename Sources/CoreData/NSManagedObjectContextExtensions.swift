// hexdreamsCocoa
// NSManagedObjectContextExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

public extension NSManagedObjectContext {

    public func hxFetch<T:NSManagedObject> (
        entity:T.Type,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false
        )
        -> [T]
    {
        do {
            let entity = NSEntityDescription.entityForClass(entityClass: T.self, inManagedObjectContext: self)
            guard let entityName = entity.name else {
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
    
    public func hxFetch<T:NSManagedObject> (
        entity:T.Type,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false,
        completion            :@escaping (NSAsynchronousFetchResult<T>)->Void
        )
    {
        do {
            let entity = NSEntityDescription.entityForClass(entityClass: T.self, inManagedObjectContext: self)
            guard let entityName = entity.name else {
                    fatalError()
            }
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            if let sortString = sortString {
                try request.sortDescriptors = NSSortDescriptor.sortDescriptorsFrom(string: sortString)
            }
            request.returnsObjectsAsFaults = returnFaults
            request.shouldRefreshRefetchedObjects = true
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest:request, completionBlock:completion)
            try self.execute(asyncRequest)
        } catch {
            fatalError()
        }
    }
    
    // Add this one so we can do trailing closures
    public func hxFetch<T:NSManagedObject> (
        entity:T.Type,
        completionBlock:@escaping (NSAsynchronousFetchResult<T>)->Void
        )
    {
        self.hxFetch(entity:entity, predicate:nil, sortString:nil, returnFaults:false, completion:completionBlock)
    }
    
    @inlinable public func hxPerform(_ block:@escaping (NSManagedObjectContext)throws->Void, hxCatch:@escaping (Error)->Void) {
        self.perform {
            do {
                try block(self)
            } catch {
                hxCatch(error)
            }
        }
    }
    
    @inlinable public func hxPerformAndWait<T>(_ block:(NSManagedObjectContext)throws->T) throws -> T {
        var blockError:Error? = nil
        var retVal:T? = nil
        
        self.performAndWait {
            do {
                retVal = try block(self)
            } catch {
                blockError = error
            }
        }
        
        try rethrow(blockError)
        
        if let val = retVal {
            return val
        }
        
        fatalError("executed block returns nil. This should never happen")
    }
    
    @inlinable public func hxTranslate<T:NSManagedObject>(foreignObject:T) throws -> T {
        let local = self.object(with:foreignObject.objectID)
        guard let typedLocal = local as? T else {
            throw HXErrors.general("Could not cast \(local) to \(T.self)")
        }
        return typedLocal
    }

    @inlinable public func hxTranslate<T:NSManagedObject>(foreignObjects:[T]) throws -> [T] {
        return try foreignObjects.map { try self.hxTranslate(foreignObject:$0) }
    }
    
    @inlinable public func hxTranslate<T:NSManagedObject>(objectID:NSManagedObjectID, entity:T.Type) throws -> T {
        let local = self.object(with:objectID)
        guard let typedLocal = local as? T else {
            throw HXErrors.general("Could not cast \(local) to \(T.self)")
        }
        return typedLocal
    }
    
    @inlinable public func hxTranslate<T:NSManagedObject>(objectIDs:[NSManagedObjectID], entity:T.Type) throws -> [T] {
        return try objectIDs.map {try self.hxTranslate(objectID:$0, entity:entity)}
    }
}
