//
//  NSManagedObjectContextTests.swift
//  hexdreamsCocoaTests
//
//  Created by Kenny Leung on 1/12/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import XCTest
import hexdreamsCocoa

class NSManagedObjectContextTests: CoreDataTestCase {

    func testFetchEntityClass() throws {
        let people = try self.moc.fetch(entity:HXManagedPerson.self)
        XCTAssertNotNil(people)
    }

    // TODO: This needs some work to wait for the asynschronous results
    func testAsynchronousFetch() throws {
        try self.moc.fetch(entity:HXManagedPerson.self, completion:{ result in
            let people = result
            XCTAssertNotNil(people)
        })
    }
    
    // TODO: This needs some work to wait for the asynschronous results
    func testAsynchronousFetchTrailing() throws {
        try self.moc.fetch(entity:HXManagedPerson.self) { result in
            let people = result
            XCTAssertNotNil(people)
        }
    }
}
