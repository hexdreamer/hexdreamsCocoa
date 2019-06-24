// hexdreamsCocoa
// HXPerson.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXPerson : NSObject {

    @objc var firstName :String?
    @objc var lastName  :String?

    init(_ firstName :String, _ lastName :String) {
        self.firstName = firstName
        self.lastName = lastName
    }

}
