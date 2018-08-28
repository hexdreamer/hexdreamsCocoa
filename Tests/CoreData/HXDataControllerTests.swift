// hexdreamsCocoa
// HXDataControllerTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import CoreData

class HXDataControllerTests: XCTestCase {

    // Declaring this without a ? or ! would mean that it would have to be set in an init() method, but we can't do that because of the rule that you would have to override ALL designated initializers, and we can't override the one that takes NSInvocation as an argument. (not available in Swift)
    lazy var dataController = {
        return HXTestDataController()
    }()

    override func setUp() {
        super.setUp()
        
        for description in self.dataController.persistentContainer.persistentStoreDescriptions {
            guard let storeURL = description.url else {
                XCTFail("no store url for \(description)")
                return
            }
            let storePath = storeURL.path
            if FileManager.default.fileExists(atPath: storePath) {
                do {
                    try FileManager.default.removeItem(at: storeURL as URL)
                } catch {
                    XCTFail("\(error)")
                }
            }
        }
        // Have to replace the dataController with a new one because of lazy initialization, and we blew away the underlying stores.
        self.dataController = HXTestDataController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUpdateEntity() {
        do {
            try self.dataController.updatePersons()
            self.dataController.queue.waitUntilAllOperationsAreFinished()
            let moc = self.dataController.viewContext
            moc.performAndWait {
                let persons = moc.hxFetch(entity:HXManagedPerson.self, predicate:nil, sortString:"personID,up", returnFaults:false)
                XCTAssertEqual(persons.count, 2);
                
                XCTAssertEqual(persons[0].personID, 1)
                XCTAssertEqual(persons[0].firstName, "Charlie")
                XCTAssertEqual(persons[0].lastName, "Brown")
                
                XCTAssertEqual(persons[1].personID, 2)
                XCTAssertEqual(persons[1].firstName, "Peppermint")
                XCTAssertEqual(persons[1].lastName, "Patty")
            }
        } catch {
            XCTFail("\(error)")
        }
    }

}
