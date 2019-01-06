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
        let people = self.moc.hxFetch(entity:HXManagedPerson.self)
        XCTAssertNotNil(people)
    }

    // TODO: This needs some work to wait for the asynschronous results
    func testAsynchronousFetch() throws {
        self.moc.hxFetch(entity:HXManagedPerson.self, completion:{ result in
            let people = result
            XCTAssertNotNil(people)
        })
    }
    
    // TODO: This needs some work to wait for the asynschronous results
    func testAsynchronousFetchTrailing() throws {
        self.moc.hxFetch(entity:HXManagedPerson.self) { result in
            let people = result
            XCTAssertNotNil(people)
        }
    }
}
