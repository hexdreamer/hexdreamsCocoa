//
//  File.swift
//  
//
//  Created by Kenny Leung on 2/18/20.
//

import XCTest
import hexdreamsCocoa

class SequenceExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJoin() {
        let dept = ["CODE", "NAME"]
        let emp = ["EMPID", "FIRST", "LAST", "DEPT_CODE"]
        var query = [(column:"FIRST",value:"Charlie"), (column:"LAST",value:"Brown")]

        // Easily generate SQL in one shot.
        XCTAssertEqual("SELECT"
            +             " D.CODE,D.NAME,E.EMPID,E.FIRST,E.LAST,E.DEPT_CODE"
            +             " FROM DEPT D,EMP E"
            +             " WHERE E.DEPT_CODE=DEPT.CODE"
            +             " AND E.FIRST='Charlie' AND E.LAST='Brown'"
            ,
                       "SELECT"
                        + " \(dept.hxjoin(",", {"D." + $0})),\(emp.hxjoin(",", {"E." + $0}))"
                        + " FROM DEPT D,EMP E"
                        + " WHERE E.DEPT_CODE=DEPT.CODE"
                        + "\(query.hxjoin(" AND ", " AND ", nil, {"E.\($0.column)='\($0.value)'"}))")

        // Drop the query
        query = []
        XCTAssertEqual("SELECT"
            +             " D.CODE,D.NAME,E.EMPID,E.FIRST,E.LAST,E.DEPT_CODE"
            +             " FROM DEPT D,EMP E"
            +             " WHERE E.DEPT_CODE=DEPT.CODE"
            ,
                       "SELECT"
                        + " \(dept.hxjoin(",", {"D." + $0})),\(emp.hxjoin(",", {"E." + $0}))"
                        + " FROM DEPT D,EMP E"
                        + " WHERE E.DEPT_CODE=DEPT.CODE"
                        + "\(query.hxjoin(" AND ", " AND ", nil, {"E.\($0.column)='\($0.value)'"}))")

        // blank content is the same as null
        XCTAssertEqual("SELECT"
            +             " D.CODE,D.NAME,E.EMPID,E.FIRST,E.LAST,E.DEPT_CODE"
            +             " FROM DEPT D,EMP E"
            +             " WHERE E.DEPT_CODE=DEPT.CODE"
            ,
                       "SELECT"
                        + " \(dept.hxjoin(",", {"D." + $0})),\(emp.hxjoin(",", {"E." + $0}))"
                        + " FROM DEPT D,EMP E"
                        + " WHERE E.DEPT_CODE=DEPT.CODE"
                        + "\(query.hxjoin(" AND ", " AND ", nil, {q in " \t\n"}))")

    }

}
