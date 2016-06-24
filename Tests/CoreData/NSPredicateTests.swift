// hexdreamsCocoa
// NSPredicateTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import XCTest

class NSPredicateTests: XCTestCase {
    
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
    
    func testInPredicate() {
        let predicate = Predicate(format: "firstName in %@", ["Charlie", "Linus"])
        let results = self.array.filter {predicate.evaluate(with: $0)}
        XCTAssertEqual(results.count, 2)
    }

    func testInPredicateWithTemplate() {
        let filterValues = ["Charlie", "Linus"]
        let results = self.filterWithTemplate(filterValues)
        XCTAssertEqual(results.count, 2)
    }

    private func filterWithTemplate<T:AnyObject>(_ input :[T]) -> [HXPerson] {
        let predicate = Predicate(format: "firstName in %@", input)
        let results = self.array.filter {predicate.evaluate(with: $0)}
        return results
    }

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
