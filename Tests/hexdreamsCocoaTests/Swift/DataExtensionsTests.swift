// hexdreamsCocoa
// DataExtensionsTest.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import Foundation

fileprivate func dataFrom(_ str:String) -> Data {
    guard let data = str.data(using:.ascii) else {
        fatalError("Couldn't initialize \(str)")
    }
    return data
}

class DataExtensionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPrefixRange() {
        let testData = dataFrom("BEGIN:VCALENDAR")
        guard let range = testData.hxrange(after:dataFrom("BEGIN:")) else {
            XCTFail("prefix not found")
            return
        }
        let value = String(data:testData[range], encoding:.ascii)
        XCTAssertEqual("VCALENDAR", value)
    }
    
}

