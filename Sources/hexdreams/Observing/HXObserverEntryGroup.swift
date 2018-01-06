// hexdreamsCocoa
// HXObserverEntryGroup.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXObserverEntryGroup : HXObserverNotification {
    
    weak var owner:AnyObject?
    let handler:((HXObserverNotification)->Void)?

    var entries = [HXObserverEntry]()
    var notifying = HXObserver.NotifyingStatus.waiting

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
        
    // MARK: - HXObserverNotification
    // This code could screw up if we cross the streams and have more than one UICoalescing notification enqueued at a time. If that happens, best thing to do is to extract the change information out into new objects. But it would be nice to not have to allocate new memory on every notification.
    func contains(observed:AnyObject) -> Bool {
        for entry in self.entries {
            if entry.observed === observed && entry.immediacy == .uicoalescing && entry.notifyingChangeCount > 0 {
                return true
            }
        }
        return false
    }
}
