// hexdreamsCocoa
// HXSynchronousObserverCenter.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

// May need to address thread safety
public class HXSynchronousObserverCenter {
    
    public static let shared:HXSynchronousObserverCenter = HXSynchronousObserverCenter()
    
    // We optimize for lookup by observed because changes are likely to happen most often.
    private var byObserved = [HXSynchronousObserverEntryGroup]()
    
    public func observe<T:AnyObject> (
        target observed:T,
        keyPath:PartialKeyPath<T>,
        notify observer:AnyObject,
        action:@escaping (AnyObject,AnyKeyPath)->Void
        ) {
        let entry = HXSynchronousObserverEntry(observed:observed, keyPath:keyPath, observer:observer, action:action)

        // Kill two birds with one stone by looking for the matching group while iterating inside removeAll
        // We only clean up when adding an observer because if you don't add any observers, it doesn't add any more weight to the system.
        var matchingGroup:HXSynchronousObserverEntryGroup?
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
            let group = HXSynchronousObserverEntryGroup(owner:observed)
            self.byObserved.append(group)
            group.entries.append(entry)
        }
    }
    
    public func removeObserver(_ observer:AnyObject) {
        for group in self.byObserved {
            for entry in group.entries {
                if entry.observer === observer {
                    entry.observer = nil
                }
            }
        }
        // We'll just let the normal clean-up processes get the stragglers. If we feel strongly about it, we could also initiate cleanup here, but it's probably not worth the cycles.
    }
    
    public func removeObserver(_ observer:AnyObject, target observed:AnyObject) {
        for group in self.byObserved {
            for entry in group.entries {
                if entry.observer === observer && entry.observed === observed {
                    entry.observer = nil
                    entry.observed = nil
                }
            }
        }
        // We'll just let the normal clean-up processes get the stragglers. If we feel strongly about it, we could also initiate cleanup here, but it's probably not worth the cycles.
    }
    
    public func removeObserver(_ observer:AnyObject, target observed:AnyObject, keyPath:AnyKeyPath) {
        for group in self.byObserved {
            for entry in group.entries {
                if entry.observer === observer && entry.observed === observed && entry.keyPath == keyPath {
                    entry.observer = nil
                    entry.observed = nil
                }
            }
        }
        // We'll just let the normal clean-up processes get the stragglers. If we feel strongly about it, we could also initiate cleanup here, but it's probably not worth the cycles.
    }

    public func changed (
        _ observed:AnyObject,
        _ keyPath:AnyKeyPath
        ) {
        for group in self.byObserved {
            if group.owner === observed {
                for entry in group.entries {
                    guard let _ = entry.observer,
                        let _ = entry.observed,
                        entry.keyPath == keyPath
                        else {
                            continue
                    }
                    entry.action(observed,entry.keyPath)
                }
                break
            }
        }
    }
    
}

