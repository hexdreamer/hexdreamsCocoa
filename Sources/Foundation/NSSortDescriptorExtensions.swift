// hexdreamsCocoa
// NSSortDescriptorExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

// FIX THIS! Should be enums
private let SORT_STRINGS_ASCENDING = ["up", "asc"]
private let SORT_STRINGS_DESCENDING = ["down", "desc"]
private let SORT_STRINGS_CASEINSENSITIVE_ASCENDING = ["ciup" , "ciasc"]
private let SORT_STRINGS_CASEINSENSITIVE_DESCENDING = ["cidown" , "cidesc"]
private let SORT_DATE_ASCENDING = ["dateup" ,"dateasc"]
private let SORT_DATE_DESCENDING = ["datedown" , "datedesc"]

extension NSSortDescriptor {

    public enum Errors: Error {
        case UnsupportedSortDirection
    }

    public class func sortDescriptorsFrom(string sortString :String) throws -> [NSSortDescriptor] {
        var descriptors = [NSSortDescriptor]()
        let components = sortString.split(pattern:"[, ]+")

        for i in stride(from: 0, to: components.count, by: 2) {
            let key = components[i]
            let direction = components[i + 1]
            var descriptor :NSSortDescriptor?

            if SORT_STRINGS_ASCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: true)
            } else if SORT_STRINGS_DESCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: false)
            } else if SORT_STRINGS_CASEINSENSITIVE_ASCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)));
            } else if SORT_STRINGS_CASEINSENSITIVE_DESCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)));
            } else if SORT_DATE_ASCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: true, selector: #selector(NSNumber.compare(_:)));
            } else if SORT_DATE_DESCENDING.contains(direction) {
                descriptor = NSSortDescriptor(key: key, ascending: false, selector: #selector(NSNumber.compare(_:)));
            }

            if let descriptor = descriptor {
                descriptors.append(descriptor)
            } else {
                throw Errors.UnsupportedSortDirection
            }
        }

        return descriptors
    }

}
