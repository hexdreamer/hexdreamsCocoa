//
//  NSEntityDescriptionTests.swift
//  hexdreamsCocoaTests
//
//  Created by Kenny Leung on 1/12/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import XCTest
import CoreData

class NSEntityDescriptionTests: CoreDataTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEntityForClass() {
        let entity = NSEntityDescription.entityForClass(entityClass:HXManagedPerson.self, inManagedObjectContext:self.pc.viewContext)
        guard let name = entity.name else {
                XCTFail()
                return
        }
        XCTAssertEqual("HXManagedPerson", name)
    }

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
 */
}
