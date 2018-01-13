// hexdreamsCocoa
// HXTestDataController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreData
import hexdreamsCocoa

class HXTestDataController: HXDataController {

    override func modelURL() -> URL {
        //guard let url = Bundle(for: type(of: self)).urlForResource("hexdreams", withExtension: "momd") else {
        guard let url = Bundle(for: type(of: self)).url(forResource:"hexdreams", withExtension: "momd") else {
            fatalError("Could not find hexdreams model")
        }
        return url;
    }

    // We can't eliminate the entityPKGetter because we need it for the PKClass. Otherwise, we can't properly declare variables like pks or mosByID
    func updateEntity<Entity:HXManagedObject,PKClass:Hashable>(
        entityClass             :Entity.Type,
        entityPKAttribute       :String,
        entityPKGetter          :@escaping (_ element :Entity) -> PKClass?,
        jsonData                :Data?,
        jsonPKGetter            :@escaping (_ dictionary :[String:AnyObject]) -> PKClass?,
        moc                     :NSManagedObjectContext,
        options                 :UpdateEntityOptions
        ) throws -> [PKClass:Entity]
    {
        guard let nnjsonData = jsonData else {
            throw Errors.BadJSON(message:"This is really BadJSON")
        }
        guard let json = try JSONSerialization.jsonObject(with: nnjsonData as Data, options: []) as? [[String:AnyObject]] else {
            throw Errors.BadJSON(message:"This is really BadJSON")
        }
        
        // We have to wrap the call to map here with our own code so we can switch types. We need [PKClass] and not [PKClass?]. If we have [PKClass?], we will trigger the "JSON primary keys \(pks) do not conform to AnyObject" below.
        // This doesn't save us any code over the "manual way" of just doing it ourselves. We need a better map method that ensures we get back non-optionals. Is that even possible? I want a generic function that returns something slightly different than it's input T vs T?
        let pks = try json.map { (dict :[String:AnyObject]) -> PKClass in
            guard let pk = jsonPKGetter(dict) else {
                throw hexdreamsCocoa.Errors.ObjectNotFound(self, "updateEntity", "Primary key not found in \(dict)")
            }
            return pk
        }

        var mosByID = [PKClass:Entity]()
        var blockError :Error? = nil
        moc.performAndWait {
            do {
                guard let entityDescription = NSEntityDescription.entityForClass(entityClass: Entity.self, inManagedObjectContext: moc) else {
                    throw Errors.EntityNotFound(message: "This is really EntityNotFound")
                }
                let predicate = NSPredicate(format: "%@ in %@", argumentArray:[entityPKAttribute, pks])
                let existingMOs = try moc.fetch(entity:entityClass, predicate: predicate, sortString: nil, returnFaults: false)
                mosByID = try existingMOs.mapDict(entityPKGetter)

                for entityDict in json {
                    guard let pk = jsonPKGetter(entityDict)
                        else {throw Errors.MissingPrimaryKey(dictionary: entityDict)}
                    let existingMO = mosByID[pk]
                    guard let mo = existingMO != nil ? existingMO : Entity(entity: entityDescription, insertInto: moc) else {
                        throw Errors.General(message: "Could not create managed object")
                    }
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

        if blockError != nil {
            throw blockError!
        }

        return mosByID
    }

    func updatePersons() throws {
        guard let url = Bundle(for: type(of: self)).url(forResource:"HXPerson", withExtension: "json") else {
            fatalError()
        }
        let jsonData = try Data(contentsOf: url)
        _ = try self.updateEntity(
            entityClass: HXManagedPerson.self,
            entityPKAttribute: "personID",
            entityPKGetter: {return $0.personID},
            jsonData: jsonData,
            jsonPKGetter: {guard let pk = $0["id"] as? Int else {return nil}; return NSNumber(value:pk)},
            moc: self.writemoc,
            options: []
        )
    }

}
