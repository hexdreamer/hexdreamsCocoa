// hexdreamsCocoa
// HXDownloadManager.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public class HXDownloadManager : NSObject, URLSessionDelegate {
    
    public struct DownloadOptions : OptionSet {
        public static let cellularAllowed = DownloadOptions(rawValue:1 << 0)
        public static let wifiOnly = DownloadOptions(rawValue:1 << 0)

        public let rawValue:Int
        public init(rawValue:Int) {
            self.rawValue = rawValue
        }
    }
    
    var runningTasks = [URLSessionDownloadTask]()

    
    public lazy var operationQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public lazy var cellularSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier:"HXResourceManagerCellular")
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.operationQueue)
        return session
    }()
    
    public lazy var wifiOnlySession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier:"HXResourceManagerCellular")
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.operationQueue)
        return session
    }()
    
    public var serialize:DispatchQueue {
        return self.operationQueue.underlyingQueue ?? {
            fatalError("Cannot get the serialize queue: The operation queue's underlyingQueue is nil")
        }
    }
    
    public func registerTask(_ task:URLSessionDownloadTask) {
        self.serialize.async {
            self.runningTasks.append(task)
            self.changed(\HXDownloadManager.runningTasks)
        }
    }
    
    public func clearCompletedTasks() {
        self.serialize.async {
            self.runningTasks.removeAll {
                $0.state == .completed
            }
            self.changed(\HXDownloadManager.runningTasks)
        }
    }
    
    public func clearErroredTasks() {
        self.serialize.async {
            self.runningTasks.removeAll {
                $0.error != nil
            }
            self.changed(\HXDownloadManager.runningTasks)
        }
    }

    public func downloadResource(
        at:URL,
        options:DownloadOptions = [.wifiOnly],
        completionHandler:@escaping (URL?,URLResponse?,Error?)->Void
        ) throws -> URLSessionDownloadTask
    {
        if options.contains(.cellularAllowed) && options.contains(.wifiOnly) {
            throw HXErrors.invalidArgument("incompatible options .cellularAllowed and .wifiOnly")
        }
        let session = options.contains(.cellularAllowed) ? self.cellularSession : self.wifiOnlySession
        let request = URLRequest(url:at)
        let task = session.downloadTask(with:request) { (burl, bresponse, berror) in
            completionHandler(burl, bresponse, berror)
            DispatchQueue.main.async {
                self.clearCompletedTasks()
            }
        }
        self.registerTask(task)
        task.resume()
        return task
    }

}
