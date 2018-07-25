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
    
    public func hxPerformAndWait(_ block:(NSManagedObjectContext)throws->Void) throws {
        var blockError:Error? = nil
        
        self.performAndWait {
            do {
                try block(self)
            } catch {
                blockError = error
            }
        }
        
        if let someError = blockError {
            throw someError
        }
    }
    
    public func hxTranslate<T:NSManagedObject>(foreignObject:T) throws -> T {
        let local = self.object(with:foreignObject.objectID)
        guard let typedLocal = local as? T else {
            throw HXErrors.general("Could not cast \(local) to \(T.self)")
        }
        return typedLocal
    }

    
}
