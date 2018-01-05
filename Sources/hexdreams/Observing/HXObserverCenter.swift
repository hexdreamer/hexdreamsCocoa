// hexdreamsCocoa
// HXObserverCenter.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXObserverCenter {
        
    public static let shared:HXObserverCenter = HXObserverCenter()
    
    private let serialize = DispatchQueue(label:"HXObserverCenter_serial", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private var byObserved = [HXObserverEntryGroup]()
    private var byObserver = [HXObserverEntryGroup]()
    private var uitimer:DispatchSourceTimer?

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
                case .timedcoaelscing:
                    if entry.notifying == .waiting {
                        entry.notifying = .scheduled
                        self.sendNotification(entry)
                    }
                case .uicoalescing:
                    if self.uitimer == nil {
                        self.startUITimer()
                    }
                }
            }
        }
    }
    
    private func sendNotification(_ entry:HXObserverEntry) {
        entry.queue.async {
            var notifyTime:DispatchTime? = nil
            
            self.serialize.sync {
                switch entry.immediacy {
                case .immediate:
                    entry.changeCount -= 1
                case .coalescing:
                    entry.changeCount = 0
                case .timedcoaelscing:
                    entry.changeCount = 0
                case .uicoalescing:
                    fatalError()
                }
                entry.notifying = .notifying
            }
            
            if let _ = entry.observed,
                let _ = entry.observer {
                guard let action = entry.action else {
                    fatalError()
                }
                action()
                notifyTime = .now()
            }
            
            self.serialize.sync {
                entry.notifying = .waiting
                if let notifyTime = notifyTime {
                    entry.lastNotifyTime = notifyTime
                }

                switch entry.immediacy {
                case .immediate:  // keep sending until they're gone
                    break
                case .coalescing:  // Every change that was enqueued before this notification is wiped out
                    if entry.changeCount > 0 {
                        entry.notifying = .scheduled
                        self.sendNotification(entry)
                    }
                case .timedcoaelscing:
                    if entry.changeCount > 0 {
                        entry.notifying = .scheduled
                        guard let intervalMS = entry.timedCoalescingIntervalMS else {
                            fatalError()
                        }
                        self.serialize.asyncAfter(deadline:.now() + .milliseconds(Int(intervalMS))) {
                            self.sendNotification(entry)
                        }
                    }
                case .uicoalescing:
                    fatalError()
                }
            }
        }
    }
    
    private func startUITimer() {
        if self.uitimer != nil {
            return
        }
        let timer = DispatchSource.makeTimerSource(flags:[], queue:serialize)
        timer.schedule(
            deadline:DispatchTime.now(),
            repeating:DispatchTimeInterval.milliseconds(Int(HXObserver.UICoalescingIntervalMS)),
            leeway:DispatchTimeInterval.milliseconds(Int(HXObserver.UICoalescingLeewayMS))
        )
        timer.setEventHandler {
            self.processUIObservers()
        }
        self.uitimer = timer
        timer.resume()
    }
    
    private func stopUITimer() {
        if let timer = self.uitimer {
            timer.cancel()
            self.uitimer = nil
        }
    }
    
    // This should be on the serialize queue by virtue of the timer.
    private func processUIObservers() {
        var hasRelevantEntries = false
        var i = self.byObserver.count - 1 ; while i >= 0 { defer {i -= 1}
            let group = self.byObserver[i]
            if group.owner == nil {
                self.byObserver.remove(at:i)
                continue
            }
            if !group.hasEntries(immediacy:.uicoalescing) {
                continue
            }
            guard let handler = group.handler else {
                fatalError()
            }
            handler(group)
            hasRelevantEntries = true
        }
        if !hasRelevantEntries {
            self.stopUITimer()
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
