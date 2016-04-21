// hexdreamsCocoa
// HXManagedPerson.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import CoreData
import hexdreamsCocoa

@objc(HXManagedPerson)
class HXManagedPerson: HXManagedObject {

    override func update(dict :[String:AnyObject]) -> Bool {
        self.personID = dict["id"] as! NSNumber?
        self.firstName = dict["firstName"] as! String?
        self.lastName = dict["lastName"] as! String?
        return true;
    }

}
