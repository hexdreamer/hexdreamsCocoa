// hexdreamsCocoa
// HXObservingExtensions
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

// You can't write an extension on AnyObject, so we'll do this for now.

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

public extension HXObject {
    func changed(_ keyPath:AnyKeyPath) {
        HXObserverCenter.shared.changed(self, keyPath)
    }
}

public extension HXThrowingObject {
    func changed(_ keyPath:AnyKeyPath) {
        HXObserverCenter.shared.changed(self, keyPath)
    }
}

public extension NSObject {
    func changed(_ keyPath:AnyKeyPath) {
        HXObserverCenter.shared.changed(self, keyPath)
    }
}

#if os(OSX)
    public extension NSWindowController {
        func observe<T:AnyObject> (
            _ observed:T?,
            _ keyPath:PartialKeyPath<T>,
            action:@escaping ()->Void
            ) {
            guard let nnobserved = observed else {
                return
            }
            HXObserverCenter.shared.observe(
                target:nnobserved,
                keyPath:keyPath,
                observer:self,
                action:action,
                queue:DispatchQueue.main,
                coalescingInterval:.milliseconds(100)
            )
        }
        
        func unobserve<T:AnyObject> (
            _ observed:T?
            ) {
            guard let nnobserved = observed else {
                return
            }
            HXObserverCenter.shared.removeObserver(self, observed:nnobserved)
        }
    }
#endif

#if os(iOS)
    public extension UIViewController {
        func observe<T:AnyObject> (
            _ observed:T,
            _ keyPath:PartialKeyPath<T>,
            action:@escaping (AnyObject,AnyKeyPath)->Void
            ) {
            HXObserverCenter.shared.observe(
                target:observed,
                keyPath:keyPath,
                notify:self,
                action:action,
                queue:DispatchQueue.main,
                coalescingInterval:.milliseconds(100)
            )
        }
        
        func unobserve<T:AnyObject> (
            _ observed:T?
            ) {
            guard let nnobserved = observed else {
                return
            }
            HXObserverCenter.shared.removeObserver(self, target:nnobserved)
        }
    }
#endif

