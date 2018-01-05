// hexdreamsCocoa
// HXObserverEntry.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXObserverEntry {
    weak var observed:AnyObject?
    let keyPath:AnyKeyPath
    weak var observer:AnyObject?
    let action:(()->Void)?
    let queue:DispatchQueue
    let immediacy:HXObserver.Immediacy
    let timedCoalescingIntervalMS:UInt?
    
    var changeCount:UInt = 0
    var notifying = HXObserver.NotifyingStatus.waiting
    var lastNotifyTime = DispatchTime.now()
    
    init (
        observed:AnyObject,
        keyPath:AnyKeyPath,
        observer:AnyObject,
        action:@escaping ()->Void,
        queue:DispatchQueue,
        immediacy:HXObserver.Immediacy,
        timedCoalescingIntervalMS:UInt?
        ) {
        self.observed = observed
        self.keyPath = keyPath
        self.observer = observer
        self.action = action
        self.queue = queue
        self.immediacy = immediacy
        self.timedCoalescingIntervalMS = timedCoalescingIntervalMS
    }
    
}
