// hexdreamsCocoa
// NSEntityDescriptionExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData

public extension NSEntityDescription {

    // With the ability now to do NSManagedObject.init(context:), this code is probably no longer needed.
    class func entityForClass(entityClass:AnyClass, inManagedObjectContext context:NSManagedObjectContext) -> NSEntityDescription {
        let entityClassName = NSStringFromClass(entityClass)

        guard let psc = context.persistentStoreCoordinator else {
            fatalError("Could not find entity for \(entityClass): persistentStoreCoordinator is nil");
        }

        for entityDescription in psc.managedObjectModel.entities {
            if entityClassName == entityDescription.managedObjectClassName {
                return entityDescription;
            }
        }

        fatalError("Could not find entity for \(entityClass)");
    }
}
