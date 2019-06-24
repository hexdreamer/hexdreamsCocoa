// hexdreamsCocoa
// HXSynchronousObserverEntry.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXSynchronousObserverEntry {
    weak var observed:AnyObject?
    let keyPath:AnyKeyPath
    weak var observer:AnyObject?
    let action:(AnyObject,AnyKeyPath)->Void
    
    init (
        observed:AnyObject,
        keyPath:AnyKeyPath,
        observer:AnyObject,
        action:@escaping (AnyObject,AnyKeyPath)->Void
        ) {
        self.observer = observer
        self.observed = observed
        self.keyPath = keyPath
        self.action = action
    }
}

class HXSynchronousObserverEntryGroup {
    weak var owner:AnyObject?
    var entries = [HXSynchronousObserverEntry]()
    
    init (owner:AnyObject) {
        self.owner = owner
    }
}

