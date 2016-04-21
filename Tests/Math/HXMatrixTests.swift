// hexdreamsCocoa
// HXMatrixTest.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa

class HXMatrixTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInverse() {
        let A = HXMatrix(rows: 2, columns: 2, values: [
            1, 2,
            3, 4
            ])
        let B = A.inverse()
        
        XCTAssert(B[0,0] == -2.0, ""); XCTAssert(B[0,1] ==  1.0, "")
        XCTAssert(B[1,0] ==  1.5, ""); XCTAssert(B[1,1] == -0.5, "")
    }
    
    func testMultiply() {
        let A = HXMatrix(rows: 3, columns: 3, values: [
            1, 2, 3,
            4, 5, 6,
            7, 8, 9
            ])
        let B = HXMatrix(rows: 3, columns: 2, values: [
            1, 4,
            2, 5,
            3, 6
            ])
        let C = A ⋅ B
        
        XCTAssert(C.rows == 3, "")
        XCTAssert(C.columns == 2, "")
        XCTAssert(C[0,0] == 14, ""); XCTAssert(C[0,1] ==  32, "")
        XCTAssert(C[1,0] == 32, ""); XCTAssert(C[1,1] ==  77, "")
        XCTAssert(C[2,0] == 50, ""); XCTAssert(C[2,1] == 122, "")
    }
    
}
