// hexdreamsCocoa
// StringExtensionsTest.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import Foundation

class StringExtensionsTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSplit() {
        let testString = "Wednesday July 23, 2014  6:00pm -  6:25pm"
        let parts = testString.split(pattern: "[ ,-]+")
        
        XCTAssertEqual(parts.count, 6, "")
        XCTAssertEqual(parts[0], "Wednesday", "")
        XCTAssertEqual(parts[1], "July", "")
        XCTAssertEqual(parts[2], "23", "")
        XCTAssertEqual(parts[3], "2014", "")
        XCTAssertEqual(parts[4], "6:00pm", "")
        XCTAssertEqual(parts[5], "6:25pm", "")
    }

}
