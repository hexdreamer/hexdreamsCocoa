// hexdreamsCocoa
// HXObserverEntry.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXObserverEntry {
    weak var observed:AnyObject?
    let keyPath:AnyKeyPath
    weak var observer:AnyObject?
    let action:(AnyObject,AnyKeyPath)->Void
    let queue:DispatchQueue
    let interval:DispatchTimeInterval
    
    var changeCount:UInt = 0
    var notifying:HXObserverCenter.NotifyingStatus = .waiting
    var lastNotifyTime:DispatchTime
    
    init (
        observed:AnyObject,
        keyPath:AnyKeyPath,
        observer:AnyObject,
        action:@escaping (AnyObject,AnyKeyPath)->Void,
        queue:DispatchQueue,
        interval:DispatchTimeInterval
        ) {
        self.observed = observed
        self.keyPath = keyPath
        self.observer = observer
        self.action = action
        self.queue = queue
        self.interval = interval
        
        self.lastNotifyTime = .now() - interval
    }
}

class HXObserverEntryGroup {
    
    weak var owner:AnyObject?
    var entries = [HXObserverEntry]()
    
    init (
        owner:AnyObject
        ) {
        self.owner = owner
    }
}
