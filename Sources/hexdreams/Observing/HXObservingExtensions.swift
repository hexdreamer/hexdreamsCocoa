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
        HXObserverCenter.shared.changed(self, keyPath:keyPath)
    }
}

public extension NSObject {
    func changed(_ keyPath:AnyKeyPath) {
        HXObserverCenter.shared.changed(self, keyPath:keyPath)
    }
}

#if os(OSX)
    public extension NSViewController {
        func observe<T:AnyObject> (
            _ observed:T,
            keyPath:PartialKeyPath<T>,
            action:@escaping ()->Void
            ) {
            HXObserverCenter.shared.observe(
                target:observed,
                keyPath:keyPath,
                observer:self,
                action:action,
                queue:DispatchQueue.main,
                coalescingInterval:.milliseconds(100)
            )
        }
    }
#endif

#if os(iOS)
    public extension UIViewController {
        func observe<T:AnyObject> (
            _ observed:T,
            keyPath:PartialKeyPath<T>,
            action:@escaping ()->Void
            ) {
            HXObserverCenter.shared.observe(
                target:observed,
                keyPath:keyPath,
                observer:self,
                action:action,
                queue:DispatchQueue.main,
                coalescingInterval:.milliseconds(100)
            )
        }
    }
#endif

