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
    
    var tasks = [HXDownloadTask]()

    
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
    
    public func clearCompletedTasks() {
        self.serialize.async {
            self.tasks.removeAll {
                $0.completed == true && $0.task?.error == nil
            }
            self.changed(\HXDownloadManager.tasks)
        }
    }
    
    public func clearErroredTasks() {
        self.serialize.async {
            self.tasks.removeAll {
                $0.completed == true && $0.task?.error != nil
            }
            self.changed(\HXDownloadManager.tasks)
        }
    }

    public func downloadResource(
        at url:URL,
        options:DownloadOptions = [.wifiOnly],
        completionHandler:@escaping (URL?,URLResponse?,Error?)->Void
        ) throws
    {
        if options.contains(.cellularAllowed) && options.contains(.wifiOnly) {
            throw HXErrors.invalidArgument("incompatible options .cellularAllowed and .wifiOnly")
        }
        
        self.serialize.async {
            
            if let existingTask = self.tasks.first(where:{$0.matches(url:url, options:options)}) {
                existingTask.appendCompletionHandler(completionHandler)
                return
            }
            
            let session = options.contains(.cellularAllowed) ? self.cellularSession : self.wifiOnlySession
            let request = URLRequest(url:url)
            let downloadTask = HXDownloadTask(options:options, completionHandler:completionHandler)
            let urlSessionTask = session.downloadTask(with:request) { (burl, bresponse, berror) in
                for handler in downloadTask.completionHandlers {
                    handler(burl, bresponse, berror)
                }
                self.clearCompletedTasks()
            }
            downloadTask.task = urlSessionTask
            self.tasks.append(downloadTask)
            urlSessionTask.resume()
        }
    }
    
}
