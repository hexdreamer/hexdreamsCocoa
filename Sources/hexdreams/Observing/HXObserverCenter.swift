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
    
    public func observe<T:AnyObject> (
        target observed:T,
        keyPath:PartialKeyPath<T>,
        notify observer:AnyObject,
        coalescingInterval:DispatchTimeInterval = .milliseconds(0),
        action:@escaping (AnyObject,AnyKeyPath)->Void
        ) {
        self.serialize.async {
            let entry = HXObserverEntry(observed:observed, keyPath:keyPath, observer:observer, interval:coalescingInterval, action:action)
            
            // Kill two birds with one stone by looking for the matching group while iterating inside removeAll
            // We only clean up when adding an observer because if you don't add any observers, it doesn't add any more weight to the system.
            var matchingGroup:HXObserverEntryGroup?
            self.byObserved.removeAll {
                if $0.owner == nil {
                    return true // block
                }
                if $0.owner === observed {
                    assert(matchingGroup == nil)
                    matchingGroup = $0
                    $0.entries.append(entry)
                }
                // May also want to remove individual entries here
                return false // block
            }
            if matchingGroup == nil {
                let group = HXObserverEntryGroup(owner:observed)
                self.byObserved.append(group)
                group.entries.append(entry)
            }
        }
    }
    
    public func observeSync<T:AnyObject> (
        target observed:T,
        keyPath:PartialKeyPath<T>,
        notify observer:AnyObject,
        action:@escaping (AnyObject,AnyKeyPath)->Void
        ) {
        HXSynchronousObserverCenter.shared.observe(target:observed, keyPath:keyPath, notify:observer, action:action)
    }

    public func removeObserver(_ observer:AnyObject) {
        // We want to do this multithreaded because we want to guarantee that observers DO NOT get called back after they call removeObserver.
        let groups = self.byObserved // makes a "copy"
        for group in groups {
            let entries = group.entries  // makes a "copy"
            for entry in entries {
                if entry.observer === observer {
                    entry.observer = nil
                }
            }
        }
        
        // We'll just let the normal clean-up processes get the stragglers. If we feel strongly about it, we could also initiate an asynchronous cleanup here, but it's probably not worth the cycles.
        HXSynchronousObserverCenter.shared.removeObserver(observer)
    }
    
    public func removeObserver(_ observer:AnyObject, target observed:AnyObject) {
        // We want to do this multithreaded because we want to guarantee that observers DO NOT get called back after they call removeObserver.
        let groups = self.byObserved // makes a "copy"
        for group in groups {
            let entries = group.entries  // makes a "copy"
            for entry in entries {
                if entry.observer === observer && entry.observed === observed {
                    entry.observer = nil
                    entry.observed = nil
                }
            }
        }

        // We'll just let the normal clean-up processes get the stragglers. If we feel strongly about it, we could also initiate an asynchronous cleanup here, but it's probably not worth the cycles.
        HXSynchronousObserverCenter.shared.removeObserver(observer, target:observed)
    }
    
    public func changed (
        _ observed:AnyObject,
        _ keyPath:AnyKeyPath
        ) {
        self.serialize.async {
            for group in self.byObserved {
                if group.owner === observed {
                    for entry in group.entries {
                        if entry.observer == nil ||
                            entry.keyPath != keyPath {
                            continue
                        }
                        
                        entry.changeCount += 1
                        if entry.notifying == .waiting {
                            entry.notifying = .scheduled
                            self.serialize.asyncAfter(deadline:entry.lastNotifyTime + entry.interval) {
                                self.sendNotification(entry)
                            }
                        }
                    }
                }
            }
            
        }
        HXSynchronousObserverCenter.shared.changed(observed, keyPath)
    }
    
    // Should only be executed from the serialize queue
    private func sendNotification(_ entry:HXObserverEntry) {
        entry.changeCount = 0
        entry.notifying = .enqueued
        DispatchQueue.main.async {
            if let observed = entry.observed,
                let _ = entry.observer {
                entry.action(observed, entry.keyPath)
            }
            let notifyTime = DispatchTime.now()
            
            self.serialize.async {
                entry.notifying = .waiting
                entry.lastNotifyTime = notifyTime
                if entry.changeCount > 0 {
                    entry.notifying = .scheduled
                    self.serialize.asyncAfter(deadline:notifyTime + entry.interval) {
                        self.sendNotification(entry)
                    }
                }
            }
        }
    }
    
}
