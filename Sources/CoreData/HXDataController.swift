// hexdreamsCocoa
// HXDataController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

// http://stackoverflow.com/questions/24393837/swift-fetch-method-with-generics

import Foundation
import CoreData

open class HXDataController {
    
    public enum Errors : Error {
        case BadJSON(message:String)
        case EntityNotFound(message:String)
        case MissingPrimaryKey(dictionary:[String:AnyObject])
        case General(message:String)
    }
    
    // Keep this, or dump?
    public struct UpdateEntityOptions : OptionSet {
        public let rawValue : Int
        static let DeleteExtras = UpdateEntityOptions(rawValue: 1)
        static let UseStreaming = UpdateEntityOptions(rawValue: 2)
        static let ErrorTolerant = UpdateEntityOptions(rawValue:4)
        
        public init(rawValue :Int) {
            self.rawValue = rawValue
        }
    }
    
    public lazy var persistentContainer:NSPersistentContainer = {
        let url = self.modelURL()
        guard let model = NSManagedObjectModel(contentsOf:url) else {
            fatalError("Could not load model at \(url)")
        }
        return NSPersistentContainer(name:self.storeName(), managedObjectModel:model)
    }()
    
    public lazy var queue:OperationQueue = {
        return OperationQueue()
    }()
    
    public lazy var urlSession:URLSession = {
        return URLSession(configuration: URLSessionConfiguration.ephemeral, delegate:nil, delegateQueue:self.queue)
    }()
    
    public var viewContext :NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    public lazy var writeContext:NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    public init() {}
    
    open func storeName() -> String {
        fatalError("Needs to be overridden")
    }
    
    open func modelURL() -> URL {
        fatalError("Needs to be overridden")
    }
    
    open func updateEntity<E:HXManagedObject,K:Hashable>(
        keyPath  :KeyPath<E,Optional<K>>,
        json     :Data?,
        pkGetter :(_ dictionary :[String:AnyObject]) -> Any?,
        moc      :NSManagedObjectContext,
        options  :UpdateEntityOptions = []
        ) throws
        -> [K:E]
    {
        guard let nnjson = json else {
            throw Errors.BadJSON(message:"JSON is null")
        }
        guard let jobjs = try JSONSerialization.jsonObject(with:nnjson as Data, options: []) as? [[String:AnyObject]] else {
            throw Errors.BadJSON(message:"Could not parse JSON")
        }
        
        let pks:[K] = try jobjs.map {
            guard let pk = pkGetter($0) as? K else {
                throw HXErrors.objectNotFound(self, "updateEntity", "Primary key not found in \($0)")
            }
            return pk  // block
        }
        
        var mosByID = [K:E]()
        var blockError:Error?
        moc.performAndWait {
            do {
                let entityDescription = NSEntityDescription.entityForClass(entityClass:E.self, inManagedObjectContext:moc)
                let predicate = NSPredicate(format: "%@ in %@", argumentArray:[keyPath, pks])
                let existingMOs = moc.fetch(entity:E.self, predicate:predicate, sortString:nil, returnFaults:false)
                mosByID = try existingMOs.mapDict{$0[keyPath:keyPath]}
                
                for entityDict in jobjs {
                    guard let pk = pkGetter(entityDict) as? K else {
                        throw Errors.MissingPrimaryKey(dictionary:entityDict)
                    }
                    let existingMO = mosByID[pk]
                    let mo = existingMO ?? E(entity:entityDescription, insertInto:moc)
                    if mo.takeValuesFrom(entityDict) {
                        if existingMO == nil {
                            mosByID[pk] = mo
                        }
                    } else {
                        throw Errors.General(message: "Error updating mo")
                    }
                }
                try moc.save();
            } catch {
                blockError = error
            }
        }
        
        if let err = blockError {
            throw err
        }
        
        return mosByID
    }
    
}


