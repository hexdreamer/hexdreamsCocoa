// hexdreamsCocoa
// NSSortDescriptorExtensionsTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import Foundation

class NSSortDescriptorExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSomething() {
        do {
            let sortDescriptors = try NSSortDescriptor.sortDescriptorsFromString("name,up, age,down, street,ciup, city,cidown, start,dateup, stop,datedown")
            XCTAssertNotNil(sortDescriptors)
            XCTAssertEqual(6, sortDescriptors.count)
            assert(sortDescriptors[0], "name",   true)
            assert(sortDescriptors[1], "age",    false)
            assert(sortDescriptors[2], "street", true)
            assert(sortDescriptors[3], "city",   false)
            assert(sortDescriptors[4], "start",  true)
            assert(sortDescriptors[5], "stop",   false)
        } catch {
            XCTFail()
        }
    }

    func testUnsupportedSortDirection() {
        do {
            let _ = try NSSortDescriptor.sortDescriptorsFromString("name,bogus")
            XCTFail()
        } catch NSSortDescriptorError.UnsupportedSortDirection {
            return
        } catch {
            XCTFail()
        }
        XCTFail()
    }

    func testOptionalMap() {
        do {
            var sortString :String?
            var sortDescriptors :[NSSortDescriptor]?

            sortString = "name,up"
            try sortDescriptors = sortString.map {try NSSortDescriptor.sortDescriptorsFromString($0)}
            XCTAssertNotNil(sortDescriptors);
            if let sortDescriptor = sortDescriptors?[0] {
                assert(sortDescriptor, "name",   true)
            }

            sortString = nil
            try sortDescriptors = sortString.map {try NSSortDescriptor.sortDescriptorsFromString($0)}
            XCTAssertNil(sortDescriptors);
        } catch {
            XCTFail()
        }
    }

    func assert(sortDescriptor :NSSortDescriptor, _ key :String, _ ascending :Bool) {
        XCTAssertEqual(key, sortDescriptor.key)
        XCTAssertEqual(ascending, sortDescriptor.ascending)
    }

}