// hexdreamsCocoa
// HXObserverCenter.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXObserverCenter {
    
    enum NotifyingStatus {
        case waiting    // doing nothing
        case scheduled  // we know we're going to send a notification
        case enqueued   // notification is enqueued on the observer's queueu
    }

    public static let shared:HXObserverCenter = HXObserverCenter()
    
    private let serialize = DispatchQueue(label:"HXObserverCenter", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private var byObserved = [HXObserverEntryGroup]()
    private var byObserver = [HXObserverEntryGroup]()
    
    public func observe<T:AnyObject> (
        target observed:T,
        keyPath:PartialKeyPath<T>,
        observer:AnyObject,
        action:@escaping ()->Void,
        queue:DispatchQueue,
        coalescingInterval:DispatchTimeInterval = .milliseconds(0)
        ) {
        self.serialize.async {
            let entry = HXObserverEntry(observed:observed, keyPath:keyPath, observer:observer, action:action, queue:queue, interval:coalescingInterval)
            
            if let group = self.findGroup(matching:observed, in:&self.byObserved) {
                group.entries.append(entry)
            } else {
                let group = HXObserverEntryGroup(owner:observed)
                self.byObserved.append(group)
                group.entries.append(entry)
            }
            
            if let group = self.findGroup(matching:observer, in:&self.byObserver) {
                group.entries.append(entry)
            } else {
                let group = HXObserverEntryGroup(owner:observer)
                self.byObserver.append(group)
                group.entries.append(entry)
            }
        }
    }
    
    public func removeObserver(_ observer:AnyObject) {
        // We want to do this multithreaded because we want to guarantee that observers DO NOT get called back after they call removeObserver.
        let observerGroups = self.byObserver // makes a "copy"
        for group in observerGroups {
            if group.owner === observer {
                let entries = group.entries  // makes a "copy"
                for entry in entries {
                    entry.observer = nil
                }
            }
        }
        
        // Now asynchronously go in and clean up
        self.serialize.async {
            var i = self.byObserver.count - 1 ; while i >= 0 { defer {i -= 1}
                let group = self.byObserver[i]
                if group.owner == nil || group.owner === observer {
                    self.byObserver.remove(at:i)
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
                if entry.notifying == .waiting {
                    entry.notifying = .scheduled
                    self.sendNotification(entry)
                }
            }
        }
    }
    
    // Should only be executed from the serialize queue
    private func sendNotification(_ entry:HXObserverEntry) {
        entry.changeCount = 0
        entry.notifying = .enqueued
        entry.queue.async {
            if let _ = entry.observed,
                let _ = entry.observer {
                entry.action()
            }
            let notifyTime = DispatchTime.now()
            
            self.serialize.async {
                entry.notifying = .waiting
                entry.lastNotifyTime = notifyTime
                if entry.changeCount > 0 {
                    entry.notifying = .scheduled
                    self.serialize.asyncAfter(deadline:.now() + entry.interval) {
                        self.sendNotification(entry)
                    }
                }
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
                for entry in group.entries {
                    entry.observed = nil
                    entry.observer = nil
                }
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
