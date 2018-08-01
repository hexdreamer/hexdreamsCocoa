//
//  HXCache.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 5/12/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

/*
 Unlike NSCache, this object caches a single chunk of data, and assumes that the data has both a locally cached (on disk) version, and a remote (canonical) version to refresh from. It also automatically manages the logic of refreshing from remote based on certain parameters (timeout for now, but possibly other strategies later). It is also memory sensitive like NSCache, and will blow the in-memory version upon a low on memory notification.
 
 load could more accurately be called "loadFromLocal", and refresh could be called refreshFromRemote, but we'll keep it short.
 
 Use HXObserving on loadState and refreshState to get alerted on data refreshes. Synchronous mode added to HXObserving to support this. (maybe we don't care about synchronous mode?)
 Observe data directly to monitor for new data (so you can refresh the UI, for instance)
 */

#if os(iOS)
import UIKit
#endif

fileprivate let serialize = DispatchQueue(label:"HXCachingWrapper", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)

public class HXCachingWrapper : HXObject {
    
    // Should be pretty obvious, but see HXCacheStateDiagram.graffle
    public enum State {
        case initial
        case running
        case succeeded
        case failed
        case cancellationRequested
        case cancelled
        case end
        
        var isTerminal:Bool {
            switch self {
            case .initial:
                return true
            case .running:
                return false
            case .succeeded:
                return true
            case .failed:
                return true
            case .cancellationRequested:
                return false
            case .cancelled:
                return true
            case .end:
                return true
            }
        }
    }
   
    // MARK: - Properties
    var loadBlock:(HXCachingWrapper)throws->[AnyObject]?
    var loadError:Error?
    public var loadState:State = .initial {
        didSet {changed(\HXCachingWrapper.loadState)}
    }
    var needsReload = false

    var refreshBlock:(HXCachingWrapper)throws->([AnyObject]?,Bool)
    var refreshError:Error?
    public var refreshState:State = .initial {
        didSet {changed(\HXCachingWrapper.refreshState)}
    }
    var refreshDate:Date?
    var refreshTimeout:TimeInterval
    
    private var _data:[AnyObject]? {
        didSet {changed(\HXCachingWrapper.data)}
    }
    public var data:[AnyObject]? {
        if self._data == nil {
            self.load()
        }
        if let rdate = self.refreshDate {
            if -rdate.timeIntervalSinceNow > self.refreshTimeout {
                self.refresh()
            }
        } else {
            self.refresh()
        }
        return self._data;
    }
    
    // MARK: - Constructors/Destructors
    public init(load:@escaping (HXCachingWrapper)throws->[AnyObject]?,
        refresh:@escaping (HXCachingWrapper)throws->([AnyObject]?,Bool),
        timeOut:TimeInterval = 600)
    {
        self.loadBlock = load
        self.refreshBlock = refresh
        self.refreshTimeout = timeOut
        super.init()
        
        #if os(iOS)
        NotificationCenter.default.addObserver(forName:UIApplication.didReceiveMemoryWarningNotification, object:nil, queue:nil) { [weak self] (note) in
            self?.invalidate()
        }
        #endif
    }
    
    #if os(iOS)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    #endif
    
    // MARK: - Load and callback methods
    
    // Return nil from the load block if it is asynchronous. Throw an error if unsuccessful.
    public func load() {
        serialize.sync {
            if !self.loadState.isTerminal {
                self.needsReload = true
                return
            }
            self.loadState = .running
        }
        do {
            if let newData = try self.loadBlock(self) {
                self._loadSucceeded(newData)
            } // else we assume load is asynchronous, and we'll get hit later in the loadCallback
        } catch {
            self._loadFailed(error)
        }
    }
    
    // You can call loadCallback multiple times. A return of a value from the completion block signals the end. Otherwise, you're still loading.
    public func loadingContinuance(propagateError:Error? = nil, performBlock:@escaping ()throws->[AnyObject]?) {
        if let error = propagateError {
            self._loadFailed(error)
            return
        }
        do {
            if let newData = try performBlock() {
                self._loadSucceeded(newData)
            }
        } catch {
            self._loadFailed(error)
        }
    }
    
    fileprivate func _loadSucceeded(_ newData:[AnyObject]) {
        serialize.async {
            self._data = newData
            serialize.async {
                self.loadState = .succeeded
                serialize.async {
                    self.loadState = .end
                    if self.needsReload {
                        DispatchQueue.main.async {
                            self.load()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func _loadFailed(_ error:Error) {
        serialize.async {
            self.loadError = error
            self.loadState = .failed
            if self.needsReload {
                DispatchQueue.main.async {
                    self.load()
                }
            }
        }
    }
    
    // Return nil from the refresh block if it is asynchronous.
    // Return of either valid data or "true" for the reload flag signals that you're done.
    public func refresh() {
        serialize.sync {
            assert(self.refreshState == .initial || self.refreshState == .end)
            self.refreshState = .running
        }
        do {
            let (newData,reload) = try self.refreshBlock(self)
            if let newData = newData {
                self._refreshSucceeded(newData, reload)
            }
        } catch {
            self._refreshFailed(error)
        }
    }
    
    // Call the refreshCallback as many times as you need to.
    // Return of either valid data or "true" for the reload flag signals that you're done.
    public func refreshingContinuance(propagateError:Error? = nil, performBlock:@escaping ()throws->([AnyObject]?,Bool)) {
        do {
            let (newData,reload) = try performBlock()
            if newData != nil || reload {
                self._refreshSucceeded(newData, reload)
            }
        } catch {
            self._refreshFailed(error)
        }
    }
    
    fileprivate func _refreshSucceeded(_ newData:[AnyObject]?, _ reload:Bool) {
        DispatchQueue.main.async {
            if newData != nil {
                self._data = newData
            }
            DispatchQueue.main.async {
                self.refreshState = .succeeded
                DispatchQueue.main.async {
                    self.refreshState = .end
                    if reload {
                        self.load()
                    }
                }
            }
        }
    }
    
    fileprivate func _refreshFailed(_ error: Error) {
        DispatchQueue.main.async {
            self.refreshError = error
            self.refreshState = .failed
        }
    }
    
    public func invalidate() {
        self._data = nil;
    }

}
