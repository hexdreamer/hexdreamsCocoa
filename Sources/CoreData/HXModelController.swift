// hexdreamsCocoa
// HXModelController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

public var HXModelControllerUpdatedNotification = "HXModelControllerUpdatedNotification"

// Needs to subclass from NSObject so it can receive notifications
public class HXModelController : NSObject {
    
    // MARK: Properties
    let modelURL :NSURL
    let storeURL :NSURL
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    } ()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error :NSError? = nil
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
        } catch var error1 as NSError {
            error = error1
        } catch {
            fatalError()
        }
        print("Initialized store at \(self.storeURL)")
        return coordinator
        }()
    
    public lazy var moc: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
    
    public lazy var writemoc: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        NSNotificationCenter.default().addObserver(self, selector: #selector(HXModelController._contextDidSave(notification:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
        return managedObjectContext
        }()

    // MARK: Constructors/Destructors
    
    public init(modelURL :NSURL, storeURL :NSURL) {
        self.modelURL = modelURL
        self.storeURL = storeURL
    }

    // MARK: Pseudo Private Methods - can't actually be declared private, or won't be found by notification
        
    func _contextDidSave(notification :NSNotification) {
        assert(notification.object as! NSManagedObjectContext == self.writemoc)
        
        if NSThread.isMainThread() {
            self.moc.mergeChanges(fromContextDidSave: notification)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.moc.mergeChanges(fromContextDidSave: notification)
                NSNotificationCenter.default().post(name: HXModelControllerUpdatedNotification, object: self)
            }
        }
    }

}
