// hexdreamsCocoa
// CGRectExtensionsTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import Foundation

class CGRectExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAspect() {
        let portrait = CGRect(x: 0, y: 0, width: 100, height: 200)
        XCTAssertTrue(portrait.isPortrait)
        XCTAssertFalse(portrait.isLandscape)
        XCTAssertFalse(portrait.isSquare)
    }

    func testInitWithSize() {
        let rect = CGRect(size: CGSize(width: 100, height: 200))
        assert(rect: rect, 0, 0, 100, 200)
    }

    func testInitWithSizeCenteredOnPoint() {
        let rect = CGRect(size: CGSize(width: 100, height: 200), centeredOn: CGPoint(x: 50, y: 50))
        assert(rect: rect, 0, -50, 100, 200)
    }

    func testInitWithSquare() {
        let rect = CGRect(square: 100, centeredOn: CGPoint(x: 100, y: 100))
        assert(rect: rect, 50, 50, 100, 100)
    }

    func testScaleAndCenterAroundPortrait() {
        let outer = CGRect(x: 0, y: 0, width: 100, height: 100)
        let inner = CGRect(x: 0, y: 0, width: 10, height: 20)
        let scaled = inner.scaleAndCenterAround(rect: outer)
        assert(rect: scaled, 0, -50, 100, 200)
    }

    func testScaleAndCenterAroundLandscape() {
        let outer = CGRect(x: 0, y: 0, width: 100, height: 100)
        let inner = CGRect(x: 0, y: 0, width: 20, height: 10)
        let scaled = inner.scaleAndCenterAround(rect: outer)
        assert(rect: scaled, -50, 0, 200, 100)
    }

    func testScaleAndCenterInPortrait() {
        let outer = CGRect(x: 0, y: 0, width: 100, height: 100)
        let inner = CGRect(x: 0, y: 0, width: 10, height: 20)
        let scaled = inner.scaleAndCenterIn(rect: outer)
        assert(rect: scaled, 25, 0, 50, 100)
    }

    func testScaleAndCenterInLandscape() {
        let outer = CGRect(x: 0, y: 0, width: 100, height: 100)
        let inner = CGRect(x: 0, y: 0, width: 20, height: 10)
        let scaled = inner.scaleAndCenterIn(rect: outer)
        assert(rect: scaled, 0, 25, 100, 50)
    }

    func assert(rect :CGRect, _ x :Int, _ y :Int, _ width :Int, _ height :Int ) {
        XCTAssertEqual(CGFloat(x), rect.origin.x)
        XCTAssertEqual(CGFloat(y),  rect.origin.y)
        XCTAssertEqual(CGFloat(width), rect.width)
        XCTAssertEqual(CGFloat(height), rect.height)
    }

}
