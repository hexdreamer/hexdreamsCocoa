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

fileprivate let serialize = DispatchQueue(label:"HXCachingWrapper", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)

public class HXCachingWrapper : HXObject {
    
    // Follows URLSessionTask.State
    public enum State {
        case running
        case suspended
        case canceling
        case completed
    }
   
    // MARK: - Properties
    let name:String
    let loadBlock:(HXCachingWrapper)throws->Any?
    var loadError:Error?  {
        didSet {
            if let error = loadError {
                print("🛑 HXCachingWrapper(\(self.name)).loadError: \(error.consoleDescription)")
            }
            changed(\HXCachingWrapper.loadError)
        }
    }
    public var loadState:State = .completed {
        didSet {changed(\HXCachingWrapper.loadState)}
    }
    var reloadNeeded = false

    let refreshBlock:(HXCachingWrapper)throws->(Any?,Bool)
    var refreshError:Error? {
        didSet {
            if let error = refreshError {
                print("🛑 HXCachingWrapper(\(self.name)).refreshError: \(error.consoleDescription)")
            }
            changed(\HXCachingWrapper.refreshError)
        }
    }
    public var refreshState:State = .completed {
        didSet {changed(\HXCachingWrapper.refreshState)}
    }
    var refreshNeeded = false
    var refreshDate:Date?
    var refreshTimeout:TimeInterval
    
    private var _data:Any? {
        didSet {changed(\HXCachingWrapper.data)}
    }
    
    public var data:Any? {
        return self._data;
    }
    
    public var dataArray:[AnyObject]? {
        return self.data as? [AnyObject]
    }
    
    // MARK: - Constructors/Destructors
    public init(
        name:String,
        load:@escaping (HXCachingWrapper)throws->Any?,
        refresh:@escaping (HXCachingWrapper)throws->(Any?,Bool),
        timeOut:TimeInterval = 600)
    {
        self.name = name
        self.loadBlock = load
        self.refreshBlock = refresh
        self.refreshTimeout = timeOut
        super.init()
        
        #if os(iOS)
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(forName:UIApplication.didReceiveMemoryWarningNotification, object:nil, queue:nil) { [weak self] (note) in
            self?.invalidate()
        }
        #else
        NotificationCenter.default.addObserver(forName:.UIApplicationDidReceiveMemoryWarning, object:nil, queue:nil) { [weak self] (note) in
        self?.invalidate()
        }
        #endif // swift(>=4.2)
        #endif // iOS
    }
    
    #if os(iOS)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    #endif
    
    // MARK: - Load and callback methods
    
    // As always, callbacks are executed on the main queue
    // Return nil from the load block if it is asynchronous.
    public func load() {
        serialize.async {
            if self.loadState != .completed {
                self.reloadNeeded = true
                return
            }
            self.loadState = .running
            self.reloadNeeded = false

            DispatchQueue.main.hxAsync({
                if let newData = try self.loadBlock(self) {
                    self._loadSucceeded(newData)
                } // else asynchronous, and client needs to finish in loadingContinuance
            }, hxCatch: {
                self._loadFailed($0)
            })
        }
    }
    
    // You can call loadingContinuance multiple times from any thread. A return of a value from the completion block signals the end. Otherwise, you're still loading.
    public func loadingContinuance(propagateError:Error? = nil, performBlock:@escaping ()throws->[AnyObject]?) {
        do {
            try rethrow(propagateError)
            if let newData = try performBlock() {
                self._loadSucceeded(newData)
            }
        } catch {
            self._loadFailed(error)
        }
    }
    
    fileprivate func _loadSucceeded(_ newData:Any) {
        serialize.async {
            self._data = newData
            self.loadState = .completed
            if self.reloadNeeded == true {
                self.load()
            }
        }
    }
    
    fileprivate func _loadFailed(_ error:Error) {
        serialize.async {
            self.loadError = error
            self.loadState = .completed
            if self.reloadNeeded == true {
                self.load()
            }
        }
    }
    
    // Return nil from the refresh block if it is asynchronous.
    // Return of either valid data or "true" for the reload flag signals that you're done.
    public func refresh() {
        serialize.async {
            if self.refreshState != .completed {
                self.refreshNeeded = true
                return
            }
            self.refreshState = .running
            self.refreshNeeded = false
            
            DispatchQueue.main.hxAsync({
                let (reloadData,reload) = try self.refreshBlock(self)
                if let newData = reloadData {
                    self._refreshSucceeded(newData, reload)
                }
            }, hxCatch: {
                self._refreshFailed($0)
            })
        }
    }
    
    // You can call refreshingContinuance multiple times from any thread
    // Return of either valid data or "true" for the reload flag signals that you're done.
    public func refreshingContinuance(propagateError:Error? = nil, performBlock:@escaping ()throws->(Any?,Bool)) {
        do {
            try rethrow(propagateError)
            let (reloadData,reload) = try performBlock()
            if reloadData != nil || reload {
                self._refreshSucceeded(reloadData, reload)
            }
        } catch {
            self._refreshFailed(error)
        }
    }
    
    fileprivate func _refreshSucceeded(_ newData:Any?, _ reload:Bool) {
        serialize.async {
            if newData != nil {
                self._data = newData
            }
            self.refreshState = .completed
            self.refreshDate = Date()
            if reload {
                self.load()
            }
            if self.refreshNeeded {
                self.refresh()
            }
        }
    }
    
    fileprivate func _refreshFailed(_ error: Error) {
        serialize.async {
            self.refreshError = error
            self.refreshState = .completed
            if self.refreshNeeded {
                self.refresh()
            }
        }
    }
    
    public func invalidate() {
        self._data = nil;
    }

}
