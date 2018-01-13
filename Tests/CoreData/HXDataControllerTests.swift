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
        let storeURL = self.dataController.storeURL()
        let storePath = storeURL.path
        if FileManager.default.fileExists(atPath: storePath) {
            do {
                try FileManager.default.removeItem(at: storeURL as URL)
            } catch {
                XCTFail("\(error)")
            }
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUpdateEntity() {
        do {
            try self.dataController.updatePersons()
            self.dataController.queue.waitUntilAllOperationsAreFinished()
            let moc = self.dataController.moc
            moc.performAndWait {
                do {
                    let persons = try moc.fetch(entity:HXManagedPerson.self, predicate: nil, sortString: "personID,up", returnFaults:false)
                    XCTAssertEqual(persons.count, 2);

                    XCTAssertEqual(persons[0].personID, 1)
                    XCTAssertEqual(persons[0].firstName, "Charlie")
                    XCTAssertEqual(persons[0].lastName, "Brown")

                    XCTAssertEqual(persons[1].personID, 2)
                    XCTAssertEqual(persons[1].firstName, "Peppermint")
                    XCTAssertEqual(persons[1].lastName, "Patty")
                } catch {
                    XCTFail("\(error)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }

}
