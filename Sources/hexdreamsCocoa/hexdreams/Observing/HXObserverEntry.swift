// hexdreamsCocoa
// HXObserverEntry.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXObserverEntry {
    weak var observed:AnyObject?
    let keyPath:AnyKeyPath
    weak var observer:AnyObject?
    let interval:DispatchTimeInterval
    let action:(AnyObject,AnyKeyPath)->Void
    
    var changeCount:UInt = 0
    var notifying:HXObserverCenter.NotifyingStatus = .waiting
    var lastNotifyTime:DispatchTime
    
    init (
        observed:AnyObject,
        keyPath:AnyKeyPath,
        observer:AnyObject,
        interval:DispatchTimeInterval,
        action:@escaping (AnyObject,AnyKeyPath)->Void
        ) {
        self.observed = observed
        self.keyPath = keyPath
        self.observer = observer
        self.interval = interval
        self.action = action
        
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
