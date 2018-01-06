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

#if os(OSX)
    extension NSViewController {
        public func observe<T:AnyObject> (
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
                immediacy:.uicoalescing,
                timedCoalescingIntervalMS:nil
            )
        }
    }
#endif

#if os(iOS)
    extension UIViewController {
        public func observe<T:AnyObject> (
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
                immediacy:.uicoalescing,
                timedCoalescingIntervalMS:nil
            )
        }
    }
#endif

