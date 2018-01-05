// hexdreamsCocoa
// HXObserverEntryGroup.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXObserverEntryGroup : HXObserverNotification {
    
    weak var owner:AnyObject?
    let handler:((HXObserverNotification)->Void)?

    var entries = [HXObserverEntry]()
    
    // optional closure arguments are automatically considered escaping, although this may cause problems of its own.
    // https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20180101/006830.html
    init (
        owner:AnyObject,
        handler:((HXObserverNotification)->Void)?
        ) {
        self.owner = owner
        self.handler = handler
    }
    
    func append(_ entry:HXObserverEntry) {
        self.entries.append(entry)
    }
    
    func hasEntries(immediacy:HXObserver.Immediacy) -> Bool {
        for entry in self.entries {
            if entry.immediacy == immediacy {
                return true
            }
        }
        return false
    }
    
    // MARK: - HXObserverNotification
    func contains(observed:AnyObject) -> Bool {
        for entry in self.entries {
            if entry.observed === observed {
                return true
            }
        }
        return false
    }
}
