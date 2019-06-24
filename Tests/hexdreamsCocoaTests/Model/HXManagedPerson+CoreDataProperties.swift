// hexdreamsCocoa
// HXManagedPerson.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

//
//  HXManagedPerson+CoreDataProperties.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/30/15.
//  Copyright © 2016 hexdreams. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension HXManagedPerson {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var personID: NSNumber?

}
