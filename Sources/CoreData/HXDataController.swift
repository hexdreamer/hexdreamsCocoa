// hexdreamsCocoa
// HXDataController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

// http://stackoverflow.com/questions/24393837/swift-fetch-method-with-generics

import Foundation
import CoreData

open class HXDataController {
    
    // MARK: - Internal Declarations
    public enum Errors : Error {
        case BadJSON(message:String)
        case EntityNotFound(message:String)
        case MissingPrimaryKey(dictionary:[String:AnyObject])
        case General(message:String)
    }
    
    // Keep this, or dump?
    public struct UpdateEntityOptions : OptionSet {
        public let rawValue : Int
        static let DeleteExtras  = UpdateEntityOptions(rawValue:1)
        static let UseStreaming  = UpdateEntityOptions(rawValue:2)
        static let ErrorTolerant = UpdateEntityOptions(rawValue:4)
        
        public init(rawValue :Int) {
            self.rawValue = rawValue
        }
    }
    
    // MARK: - Configuration Properties
    open var serverURL:String {
        fatalError("You must return serverURL from \(self).serverURL")
    }
    
    open var storeName:String {
        fatalError("Needs to be overridden")
    }
    
    open var modelURL:URL {
        fatalError("Needs to be overridden")
    }
        
    // MARK: - Properties
    public lazy var queue:OperationQueue = {
        let q = OperationQueue()
        q.name = "HXDataController"
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .background
        return q
    }()
    
    public lazy var urlSession:URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 10
        if #available(iOS 11.0, *) {
            config.waitsForConnectivity = false
        }
        return URLSession(configuration:config, delegate:nil, delegateQueue:self.queue)
    }()
    
    public lazy var persistentContainer:NSPersistentContainer = {
        let url = self.modelURL
        guard let model = NSManagedObjectModel(contentsOf:url) else {
            fatalError("Could not load model at \(url)")
        }
        let cont = NSPersistentContainer(name:self.storeName, managedObjectModel:model)
        cont.loadPersistentStores(completionHandler:{ (description, error) in
            print("Loaded persistent stores:\(description)")
            if let e = error {
                fatalError("\(e)")
            }
        })
        return cont
    }()
    
    public var viewContext :NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    public lazy var writeContext:NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    // MARK: - Constructors/Destructors
    public init() {}
    
    // MARK: - Methods
    /*
     Refresh an entity from the server
     */
    open func refreshEntity<E:HXManagedObject,K:Hashable>(
        urlFragment    :String,
        primaryKeyPath :KeyPath<E,Optional<K>>,
        pkGetter       :@escaping (_ dictionary:[String:AnyObject])->Any? = {$0["id"]},
        moc            :NSManagedObjectContext? = nil,
        options        :UpdateEntityOptions = [],
        additionalProcessing: ((_ managedObjects:[E])->Void)? = nil
        )
    {
        guard let url = URL(string:self.serverURL + urlFragment) else {
            fatalError("could not initialize URL \(self.serverURL)\(urlFragment)")
        }
        let request = URLRequest(url:url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval:10)
        let task = URLSession.shared.dataTask(with:request) { [weak self] (data, response, error) in
            guard let this = self else {
                return // block
            }
            guard let nndata = data else {
                print("no data received -- log better")
                return // block
            }
            do {
                let mos = try this.updateEntity(primaryKeyPath :primaryKeyPath,
                                                primaryKeyName :"id",
                                                json           :nndata,
                                                pkGetter       :pkGetter,
                                                moc            :moc ?? this.writeContext,
                                                options        :[]
                )
                if let processing = additionalProcessing {
                    processing(mos)
                }
            } catch {
                
            }
        }
        task.resume()
    }

    open func urlRequest(_ urlString:String) throws -> URLRequest {
        guard let url = URL(string:urlString) else {
            throw HXErrors.invalidArgument(.info(self,"could not initialize URL \(urlString)"))
        }
        let request = URLRequest(url:url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval:10)
        return request
    }
    
    /*
     Update an entity with the given JSON data from the server
     Returns an array of the updated objects. The objects come from the specified moc.
     */
    open func updateEntity<E:HXManagedObject,K:Hashable>(
        primaryKeyPath :KeyPath<E,Optional<K>>,
        primaryKeyName :String,
        json           :Data,
        pkGetter       :(_ dictionary :[String:AnyObject]) -> Any?,
        moc            :NSManagedObjectContext,
        options        :UpdateEntityOptions = []
        ) throws
        -> [E]
    {
        // We probably want to stick to NSJSONSerialization because all the types will already be CoreData compatible.
        var parsedjson:Any? = nil
        do {
            parsedjson = try JSONSerialization.jsonObject(with:json, options: [])
        } catch {
            let jsonString = String(data:json, encoding:.utf8) ?? "null"
            throw HXErrors.cocoa(.info(self,"Error parsing JSON:\n\(jsonString.head(20))", causingErrors:[error]))
        }
        
        guard let jsonObjs = parsedjson as? [[String:AnyObject]] else {
            let jsonString = String(data:json, encoding:.utf8) ?? "null"
            throw Errors.BadJSON(message:"Error parsing JSON: \(jsonString)")
        }
        let pks:[K] = try jsonObjs.map {
            guard let pk = pkGetter($0) as? K else {
                throw HXErrors.objectNotFound(.info(self,"Primary key not found in \($0)"))
            }
            return pk  // block
        }
                
        return try moc.hxPerformAndWait {
            let predicate = NSPredicate(format: "\(primaryKeyName) in %@", argumentArray:[pks])
            let existingMOs = $0.hxFetch(entity:E.self, predicate:predicate)
            var mosByID = try existingMOs.mapDict{$0[keyPath:primaryKeyPath]}
            var updatedMOs = [E]()
            
            for entityDict in jsonObjs {
                guard let pk = pkGetter(entityDict) as? K else {
                    throw Errors.MissingPrimaryKey(dictionary:entityDict)
                }
                let existingMO = mosByID[pk]
                let mo = existingMO ?? E(context:$0)
                if ( !mo.takeValuesFrom(entityDict) ) {
                    throw Errors.General(message:"takeValuesFrom failed")
                }
                if existingMO == nil {
                    mosByID[pk] = mo
                }
                updatedMOs.append(mo)
            }
            try $0.save();
            return updatedMOs // block
        }
    }
}


