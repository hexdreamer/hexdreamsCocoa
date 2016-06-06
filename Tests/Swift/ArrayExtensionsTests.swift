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
        let newArray = self.map(self.array) {return $0.lastName!}
        XCTAssertEqual(newArray, ["Brown", "Patti", "Van Pelt"])
    }

    private func map<E,K>(
        _ array :Array<E>,
        keyGetter :(element :E) -> K
        ) -> [K]
    {
        return array.map(keyGetter)
    }

    func testMapDict() {
        do {
            let dict = try self.array.mapDict {$0.firstName}

            XCTAssertEqual(dict["Charlie"]!.lastName!, self.array[0].lastName!)
            XCTAssertEqual(dict["Peppermint"]!.lastName!, self.array[1].lastName!)
            XCTAssertEqual(dict["Linus"]!.lastName!, self.array[2].lastName!)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMapDictIndirect() {
        do {
            let dict = try self.mapDict(self.array) {$0.lastName}

            XCTAssertEqual(dict["Brown"]!.lastName!, self.array[0].lastName!)
            XCTAssertEqual(dict["Patti"]!.lastName!, self.array[1].lastName!)
            XCTAssertEqual(dict["Van Pelt"]!.lastName!, self.array[2].lastName!)
        } catch {
            XCTFail("\(error)")
        }
    }

    private func mapDict<E,K>(
        _ array :Array<E>,
        keyGetter :(element :E) -> K?
        ) throws -> Dictionary<K,E>
    {
        return try array.mapDict(keyGetter)
    }

    func testMissingKey() {
        var errorEncountered = false
        do {
            self.array.last?.lastName = nil
            let _ = try self.array.mapDict {$0.lastName}
            XCTFail()
        } catch hexdreams.Error.ObjectNotFound {
            errorEncountered = true
        } catch {
            XCTFail("\(error)")
        }
        XCTAssertTrue(errorEncountered)
    }

}
