// hexdreamsCocoa
// CaptureListConditionalTests.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

/*
  Tests to support Kurt's request for automatically skipping an entire block if [weak self] evaluates to nil. i.e. self has gone away.
*/

import XCTest

class CaptureListConditionalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWeakSelfOldWay() {
        weak var me = self
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            guard let me = me else {return}
            me.doitOutOfBand("testWeakSelfOldWay")
        }
    }
    
    func testWeakSelf() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self] in
            // can't do 'guard let self = self else {return}'
            guard let me = self else {return}
            me.doitOutOfBand("testWeakSelf")
        }
    }

    func testWeakSelfAndOthers() {
        let other = OtherClass()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self, weak other] in
            guard let me = self, other = other else {return}
            
            me.doitOutOfBand("testWeakSelfAndOthers")
            other.beautiful = true
        }
    }

    /*
    This is what we'd like to be able to do:
     
    func testWeakSelfWithConditional() {
        let other1 = OtherClass()
        let other2 = OtherClass()

        // Question mark after capture list means check all for nil
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self, other1, weak other2]? in
            // everything in capture list already guaranteed to be non-nil
            self.doitOutOfBand("testWeakSelfWithConditional")
            other1.beautiful = true
            other2.beautiful = false
        }
    }
    */

    /*
    This can't be done, so you can never use self inside the block.
    func testWeakSelfRenamingSelf() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak x = self] in
            guard let self = x else {return}
            self.doitOutOfBand("testWeakSelfRenamingSelf")
        }
    }
    */
    
    func doitOutOfBand(_ message :String) {
        print("Doing it to \(message)\n")
    }
}


class OtherClass {
    var beautiful :Bool
    
    init() {
        beautiful = false
    }
}