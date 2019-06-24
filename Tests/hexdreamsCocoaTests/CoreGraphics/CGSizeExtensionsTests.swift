// hexdreamsCocoa
// CGSizeExtensionsTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import Foundation

class CGSizeExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAll() {
        let size = CGSize(width: 30, height: 40)
        XCTAssertEqual(0.75, size.aspect)
        XCTAssertTrue(size.isPortrait)
        XCTAssertFalse(size.isLandscape)
        XCTAssertFalse(size.isSquare)
    }

    func testSquare() {
        let size = CGSize(width: 100, height: 100)
        XCTAssertEqual(1.0, size.aspect)
        XCTAssertFalse(size.isPortrait)
        XCTAssertFalse(size.isLandscape)
        XCTAssertTrue(size.isSquare)
    }
}