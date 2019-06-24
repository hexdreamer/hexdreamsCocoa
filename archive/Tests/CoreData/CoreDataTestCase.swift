//
//  CoreDataTests.swift
//  hexdreamsCocoaTests
//
//  Created by Kenny Leung on 1/12/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import XCTest
import CoreData

class CoreDataTestCase: XCTestCase {

    lazy var pc:NSPersistentContainer = {
        guard let url = Bundle(for:type(of:self)).url(forResource:"hexdreams", withExtension:".momd") else {
            fatalError("Could not find hexdreams.eomodeld")
        }
        guard let mom = NSManagedObjectModel(contentsOf:url) else {
            fatalError("Could not initialize model from \(url)")
        }
        let container = NSPersistentContainer(name:"hexdreams", managedObjectModel:mom)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    var moc:NSManagedObjectContext {
        return self.pc.viewContext
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
