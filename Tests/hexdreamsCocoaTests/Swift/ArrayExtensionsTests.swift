// hexdreamsCocoa
// ArrayExtensionsTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest
import hexdreamsCocoa
import CoreData

class ArrayExtensionsTests: XCTestCase {

    var array = [HXPerson]()

    override func setUp() {
        super.setUp()

        array = [HXPerson]()
        array.append(HXPerson("Charlie", "Brown"))
        array.append(HXPerson("Peppermint", "Patti"))
        array.append(HXPerson("Linus", "Van Pelt"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMap() {
        let newArray = self.array.map {$0.firstName!}
        XCTAssertEqual(newArray, ["Charlie", "Peppermint", "Linus"])
    }

    func testMapIndirect() {
        let newArray = self.map(self.array) {$0.lastName!}
        XCTAssertEqual(newArray, ["Brown", "Patti", "Van Pelt"])
    }

    private func map<E,K>(
        _ array :Array<E>,
        keyGetter :(_ element :E) -> K
        ) -> [K]
    {
        return array.map(keyGetter)
    }

    func testMapDict() {
        let dict = self.array.mapDict {$0.firstName}
        
        XCTAssertEqual(dict["Charlie"]!.lastName!,    self.array[0].lastName!)
        XCTAssertEqual(dict["Peppermint"]!.lastName!, self.array[1].lastName!)
        XCTAssertEqual(dict["Linus"]!.lastName!,      self.array[2].lastName!)
    }

    func testMissingKey() {
        self.array.last?.lastName = nil
        let _ = self.array.mapDict {$0.lastName}
    }
}
