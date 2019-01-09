// hexdreamsCocoa
// NSManagedObjectContextExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

// General convention: if you are passed a MOC to perform operations in, you will assume that you are already in a perform block. This will prevent deadlocks of performs within performs.

public extension NSManagedObjectContext {

    func hxFetch<T:NSManagedObject> (
        entity:T.Type,
        predicate             :NSPredicate? = nil,
        sortString            :String? = nil,
        returnFaults          :Bool = false
        )
        -> [T]
    {
        do {
            let entity = NSEntityDescription.entityForClass(entityClass:T.self, inManagedObjectContext:self)
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
    
    func hxFetch<T:NSManagedObject> (
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
    func hxFetch<T:NSManagedObject> (
        entity:T.Type,
        completionBlock:@escaping (NSAsynchronousFetchResult<T>)->Void
        )
    {
        self.hxFetch(entity:entity, predicate:nil, sortString:nil, returnFaults:false, completion:completionBlock)
    }
    
    @inlinable func hxPerform(_ block:@escaping (NSManagedObjectContext)throws->Void, hxCatch:@escaping (Error)->Void) {
        self.perform {
            do {
                try block(self)
            } catch {
                self.rollback()
                hxCatch(error)
            }
        }
    }
    
    // https://oleb.net/blog/2018/02/performandwait/
    func hxPerformAndWait<T>(_ block: (NSManagedObjectContext) throws -> T) rethrows -> T {
        return try _performAndWaitHelper(
            fn: performAndWait, execute: block, rescue: { throw $0 }
        )
    }
    
    /// Helper function for convincing the type checker that
    /// the rethrows invariant holds for performAndWait.
    ///
    /// Source: https://github.com/apple/swift/blob/bb157a070ec6534e4b534456d208b03adc07704b/stdlib/public/SDK/Dispatch/Queue.swift#L228-L249
    private func _performAndWaitHelper<T>(
        fn: (() -> Void) -> Void,
        execute work: (NSManagedObjectContext) throws -> T,
        rescue: ((Error) throws -> (T))) rethrows -> T
    {
        var result: T?
        var error: Error?
        withoutActuallyEscaping(work) { _work in
            fn {
                do {
                    result = try _work(self)
                } catch let e {
                    self.rollback()
                    error = e
                }
            }
        }
        if let e = error {
            return try rescue(e)
        } else {
            return result!
        }
    }

    @inlinable func hxTranslate<T:NSManagedObject>(foreignObject:T) throws -> T {
        let local = self.object(with:foreignObject.objectID)
        guard let typedLocal = local as? T else {
            throw HXErrors.general(.info(self,"Could not cast \(local) to \(T.self)"))
        }
        return typedLocal
    }

    @inlinable func hxTranslate<T:NSManagedObject>(foreignObjects:[T]) throws -> [T] {
        return try foreignObjects.map { try self.hxTranslate(foreignObject:$0) }
    }
    
    @inlinable func hxTranslate<T:NSManagedObject>(objectID:NSManagedObjectID, entity:T.Type) throws -> T {
        let local = self.object(with:objectID)
        guard let typedLocal = local as? T else {
            throw HXErrors.general(.info(self,"Could not cast \(local) to \(T.self)"))
        }
        return typedLocal
    }
    
    @inlinable func hxTranslate<T:NSManagedObject>(objectIDs:[NSManagedObjectID], entity:T.Type) throws -> [T] {
        return try objectIDs.map {try self.hxTranslate(objectID:$0, entity:entity)}
    }
}
