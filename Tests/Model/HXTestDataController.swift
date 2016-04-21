// hexdreamsCocoa
// HXTestDataController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit
import hexdreamsCocoa
import CoreData

class HXTestDataController: HXDataController {

    override func modelURL() -> NSURL {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("hexdreams", withExtension: "momd") else {
            fatalError("Could not find hexdreams model")
        }
        return url;
    }

    // We can't eliminate the entityPKGetter because we need it for the PKClass. Otherwise, we can't properly declare variables like pks or mosByID
    func updateEntity<Entity:HXManagedObject,PKClass:Hashable>(
        entityClass entityClass :Entity.Type,
        entityPKAttribute       :String,
        entityPKGetter          :(element :Entity) -> PKClass?,
        jsonData                :NSData?,
        jsonPKGetter            :(dictionary :[String:AnyObject]) -> PKClass?,
        moc                     :NSManagedObjectContext,
        options                 :UpdateEntityOptions
        ) throws -> [PKClass:Entity]
    {
        guard let nnjsonData = jsonData else {
            throw Errors.BadJSON(message:"This is really BadJSON")
        }
        guard let json = try NSJSONSerialization.JSONObjectWithData(nnjsonData, options: []) as? [[String:AnyObject]] else {
            throw Errors.BadJSON(message:"This is really BadJSON")
        }
        
        // We have to wrap the call to map here with our own code so we can switch types. We need [PKClass] and not [PKClass?]. If we have [PKClass?], we will trigger the "JSON primary keys \(pks) do not conform to AnyObject" below.
        // This doesn't save us any code over the "manual way" of just doing it ourselves. We need a better map method that ensures we get back non-optionals. Is that even possible? I want a generic function that returns something slightly different than it's input T vs T?
        let pks = try json.map { (dict :[String:AnyObject]) -> PKClass in
            guard let pk = jsonPKGetter(dictionary: dict) else {
                throw hexdreams.Error.ObjectNotFound(self, "updateEntity", "Primary key not found in \(dict)")
            }
            return pk
        }

        var mosByID = [PKClass:Entity]()
        var blockError :ErrorType? = nil
        moc.performBlockAndWait {
            do {
                guard let entityDescription = NSEntityDescription.entityForClass(Entity.self, inManagedObjectContext: moc)else {
                    throw Errors.EntityNotFound(message: "This is really EntityNotFound")
                }
                guard let entityName = entityDescription.name else {
                    throw Errors.EntityNotFound(message:"This is really EntityNotFound")
                }
                guard let inList = pks as? AnyObject else {
                    throw Errors.General(message: "JSON primary keys \(pks) do not conform to AnyObject")
                }
                let predicate = NSPredicate(format: "%@ in %@", argumentArray:[entityPKAttribute, inList])
                guard let existingMOs = try moc.fetch(entityName: entityName, predicate: predicate, sortString: nil, returnFaults: false) as? Array<Entity>
                    else {throw Errors.General(message: "Error fetching existing objects")}
                mosByID = try existingMOs.mapDict(entityPKGetter)

                for entityDict in json {
                    guard let pk = jsonPKGetter(dictionary: entityDict)
                        else {throw Errors.MissingPrimaryKey(dictionary: entityDict)}
                    let existingMO = mosByID[pk]
                    guard let mo = existingMO != nil ? existingMO : Entity(entity: entityDescription, insertIntoManagedObjectContext: moc) else {
                        throw Errors.General(message: "Could not create managed object")
                    }
                    if mo.update(entityDict) {
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

        if blockError != nil {
            throw blockError!
        }

        return mosByID
    }

    func updatePersons() throws {
        let url = NSBundle(forClass: self.dynamicType).URLForResource("HXPerson", withExtension: "json")
        let jsonData = NSData(contentsOfURL: url!)
        try self.updateEntity(
            entityClass: HXManagedPerson.self,
            entityPKAttribute: "personID",
            entityPKGetter: {return $0.personID},
            jsonData: jsonData,
            jsonPKGetter: {guard let pk = $0["id"] as? Int else {return nil}; return NSNumber(integer:pk)},
            moc: self.writemoc,
            options: []
        )
    }

}
