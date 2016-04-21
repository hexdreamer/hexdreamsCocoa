// hexdreamsCocoa
// NSEntityDescriptionExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData

public extension NSEntityDescription {

    class func entityForClass(entityClass: AnyClass, inManagedObjectContext context: NSManagedObjectContext) -> NSEntityDescription? {
        let entityClassName = NSStringFromClass(entityClass)

        guard let psc = context.persistentStoreCoordinator else {
            return nil;
        }

        for entityDescription in psc.managedObjectModel.entities {
            if entityClassName == entityDescription.managedObjectClassName {
                return entityDescription;
            }
        }

        return nil;
    }
}