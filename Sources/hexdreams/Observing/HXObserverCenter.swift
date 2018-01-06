// hexdreamsCocoa
// HXObserverCenter.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

// NOTE: Need to work on the notifying state thing some more. Do we have all of the states? Let's think about each of the 4 cases individually in terms of lifecycle.

import Foundation

public class HXObserverCenter {
        
    public static let shared:HXObserverCenter = HXObserverCenter()
    
    private let serialize = DispatchQueue(label:"HXObserverCenter", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private var byObserved = [HXObserverEntryGroup]()
    private var byObserver = [HXObserverEntryGroup]()
    private var uiTimer:DispatchSourceTimer?

    public func register (
        observer:AnyObject,
        handler:@escaping (HXObserverNotification)->Void
        ) {
        self.serialize.async {
            if let _ = self.findGroup(matching: observer, in: &self.byObserver) {
                fatalError("Can't register the same observer twice")
            }
            self.byObserver.append(HXObserverEntryGroup(owner: observer, handler: handler))
        }
    }
    
    public func observe<T:AnyObject> (
        target observed:T,
        keyPath:PartialKeyPath<T>,
        observer:AnyObject,
        action:@escaping ()->Void,
        queue:DispatchQueue,
        immediacy:HXObserver.Immediacy,
        timedCoalescingIntervalMS:UInt?
        ) {
        serialize.async {
            let entry = HXObserverEntry(observed:observed, keyPath:keyPath, observer:observer, action:action, queue:queue, immediacy:immediacy, timedCoalescingIntervalMS:timedCoalescingIntervalMS)
            
            if let group = self.findGroup(matching: observed, in: &self.byObserved) {
                group.append(entry)
            } else {
                let group = HXObserverEntryGroup(owner:observed, handler:nil)
                group.append(entry)
                self.byObserved.append(group)
            }
            
            if let group = self.findGroup(matching: observer, in: &self.byObserver) {
                group.append(entry)
            } else {
                if immediacy == .uicoalescing {
                    fatalError("Can only observe uicoalescing after you've registered a handler")
                }
                let group = HXObserverEntryGroup(owner:observed, handler:nil)
                group.append(entry)
                self.byObserver.append(group)
            }
            
            if immediacy == .uicoalescing {
                if queue != DispatchQueue.main {
                    fatalError("uicoalescing can only be specified on the main queue")
                }
            }
        }
    }
    
    public func changed (
        _ observed:AnyObject,
        keyPath:AnyKeyPath
        ) {
        self.serialize.async {
            guard let group = self.findGroup(matching: observed, in: &self.byObserved) else {
                return  // block
            }
            
            for entry in group.entries {
                if entry.observer == nil ||
                    entry.keyPath != keyPath {
                    continue
                }
                
                entry.changeCount += 1
                
                switch entry.immediacy {
                case .immediate:
                    self.sendNotification(entry)
                case .coalescing:
                    if entry.notifying == .waiting {
                        entry.notifying = .scheduled
                        self.sendNotification(entry)
                    }
                case .timedcoalescing:
                    if entry.notifying == .waiting {
                        entry.notifying = .scheduled
                        self.sendNotification(entry)
                    }
                case .uicoalescing:
                    if self.uiTimer == nil {
                        self.startUITimer()
                    }
                }
            }
        }
    }
    
    private func sendNotification(_ entry:HXObserverEntry) {
        self.serialize.async {
            if entry.notifying == .notifying {
                return // block
            }
            guard let _ = entry.observed,
                let _ = entry.observer else {
                    return // block
            }
            
            switch entry.immediacy {
            case .immediate:
                entry.notifyingChangeCount += 1
                entry.changeCount -= 1
            case .coalescing:
                entry.notifyingChangeCount = entry.changeCount
                entry.changeCount = 0
            case .timedcoalescing:
                entry.notifyingChangeCount = entry.changeCount
                entry.changeCount = 0
            case .uicoalescing:
                fatalError()
            }
            
            guard let action = entry.action else {
                fatalError()
            }
            
            entry.notifying = .notifying
            entry.queue.async {
                action()
                let notifyTime = DispatchTime.now()
                
                self.serialize.async {
                    entry.notifying = .waiting
                    entry.lastNotifyTime = notifyTime
                    
                    switch entry.immediacy {
                    case .immediate:        // immediate notifications have already been put on the queue
                        entry.notifyingChangeCount -= 1
                        break
                    case .coalescing:       // Every change that was enqueued before this notification was wiped out
                        entry.notifyingChangeCount = 0
                        if entry.changeCount > 0 {
                            entry.notifying = .scheduled
                            self.sendNotification(entry)
                        }
                    case .timedcoalescing:  // Every change that was enqueued before this notification was wiped out
                        entry.notifyingChangeCount = 0
                        if entry.changeCount > 0 {
                            entry.notifying = .scheduled
                            guard let intervalMS = entry.timedCoalescingIntervalMS else {
                                fatalError()
                            }
                            self.serialize.asyncAfter(deadline:.now() + .milliseconds(Int(intervalMS))) {
                                self.sendNotification(entry)
                            }
                        }
                    case .uicoalescing:     // UICoalescing notifications are handled by the timer
                        fatalError()
                    }
                }
            }
        }
    }
    
    private func startUITimer() {
        if self.uiTimer != nil {
            return
        }
        let timer = DispatchSource.makeTimerSource(flags:[], queue:DispatchQueue.global())
        timer.schedule(
            deadline:DispatchTime.now(),
            repeating:DispatchTimeInterval.milliseconds(Int(HXObserver.UICoalescingIntervalMS)),
            leeway:DispatchTimeInterval.milliseconds(Int(HXObserver.UICoalescingLeewayMS))
        )
        timer.setEventHandler {
            self.sendUINotifications()
        }
        self.uiTimer = timer
        timer.resume()
    }
    
    private func stopUITimer() {
        if let timer = self.uiTimer {
            timer.cancel()
            self.uiTimer = nil
        }
    }
    
    private func sendUINotifications() {
        self.serialize.async {
            var hasRelevantEntries = false
            var i = self.byObserver.count - 1 ; while i >= 0 { defer {i -= 1}
                let group = self.byObserver[i]
                if group.owner == nil {
                    self.byObserver.remove(at:i)
                    continue
                }
                if group.notifying == .notifying {
                    continue
                }
                
                var shouldNotify = false
                for entry in group.entries {
                    if entry.immediacy == .uicoalescing && entry.changeCount > 0 {
                        entry.notifyingChangeCount = entry.changeCount
                        entry.changeCount = 0
                        shouldNotify = true
                    }
                }
                if !shouldNotify {
                    continue
                }
                
                guard let handler = group.handler else {
                    fatalError()
                }
                
                group.notifying = .notifying
                DispatchQueue.main.async {
                    handler(group)
                    
                    self.serialize.async {
                        group.notifying = .waiting
                        for entry in group.entries {
                            if entry.immediacy == .uicoalescing {
                                entry.notifyingChangeCount = 0
                            }
                        }
                    }
                }
                
                hasRelevantEntries = true
            }
            if !hasRelevantEntries {
                self.stopUITimer()
            }
        }
    }
    
    private func findGroup (
        matching owner:AnyObject,
        in array:inout [HXObserverEntryGroup]
        )
        -> HXObserverEntryGroup?
    {
        var match:HXObserverEntryGroup? = nil
        var i = array.count - 1 ; while i >= 0 { defer {i -= 1}
            let group = array[i]
            if group.owner == nil {
                array.remove(at:i)
                continue
            }
            if group.owner === owner {
                if match != nil {
                    fatalError("Same owner is registered twice")
                }
                match = group
            }
        }
        return match
    }

}
