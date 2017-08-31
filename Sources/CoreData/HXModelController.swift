// hexdreamsCocoa
// HXModelController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData

// Needs to subclass from NSObject so it can receive notifications
public class HXModelController : NSObject {

    static let UpdatedNotification = Notification.Name("HXModelControllerUpdatedNotification")

    // MARK: Properties
    let modelURL :URL
    let storeURL :URL
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL as URL)!
    } ()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error :NSError? = nil
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL as URL, options: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(HXModelController._contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        return managedObjectContext
        }()

    // MARK: Constructors/Destructors
    
    public init(modelURL :URL, storeURL :URL) {
        self.modelURL = modelURL
        self.storeURL = storeURL
    }

    // MARK: Pseudo Private Methods - can't actually be declared private, or won't be found by notification
        
    @objc func _contextDidSave(notification :Notification) {
        assert(notification.object as! NSManagedObjectContext == self.writemoc)
        
        if Thread.isMainThread {
            self.moc.mergeChanges(fromContextDidSave: notification)
        } else {
            DispatchQueue.main.async {
                self.moc.mergeChanges(fromContextDidSave: notification)
                NotificationCenter.default.post(name: HXModelController.UpdatedNotification, object: self)
            }
        }
    }

}
