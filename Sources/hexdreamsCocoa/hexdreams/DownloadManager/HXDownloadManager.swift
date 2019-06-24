// hexdreamsCocoa
// HXDownloadManager.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

/*
 A DownloadTask is the work unit of the DownloadManager. A DownloadTask may be associated with multiple DownloadJobs. DownloadJobs are essentially receipts for requests by the client to download something. So if you issue multiple requests for the same URL, there will be one Task, but multiple Jobs. The client can ask the DownloadManager to cancel a Job.
 */

import Foundation

public class HXDownloadManager : NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    
    public struct DownloadOptions : OptionSet {
        public static let cellularAllowed = DownloadOptions(rawValue:1 << 0)
        public static let immediate = DownloadOptions(rawValue:1 << 1)

        public let rawValue:Int
        public init(rawValue:Int) {
            self.rawValue = rawValue
        }
    }
    
    public static let shared:HXDownloadManager = HXDownloadManager()
    
    private let serialize = DispatchQueue(label:"HXDownloadManager.serialize", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private lazy var serializationQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = self.serialize
        return queue
    }()
    private let delegateQueue = DispatchQueue(label:"HXDownloadManager.execute", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private lazy var tempDirectory:URL = {
        do {
            // We don't know where this file is ultimately going to go, but it's probably going to be stored by HXStorageManager, so we'll fake it to the same general area.
            let fakeDestination = try FileManager.default.url(for:.applicationSupportDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            return try FileManager.default.url(for:.itemReplacementDirectory, in:.userDomainMask, appropriateFor:fakeDestination, create:true)
        } catch {
            fatalError("Error generating tempDirectory for HXDownloadManager: \(error)")
        }
    }()

    var cache = [HXDownloadTask]()
    var tasks = [HXDownloadTask]()

    public lazy var cellularSession:URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.serializationQueue)
        return session
    }()
    
    public lazy var wifiOnlySession:URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.allowsCellularAccess = true
        let session = URLSession(configuration:config, delegate:self, delegateQueue:self.serializationQueue)
        return session
    }()
    
    public func downloadResource(
        at url:URL,
        to destinationURL:URL? = nil,
        options:DownloadOptions = [],
        readyQueue:DispatchQueue? = nil,
        dataReady:@escaping (HXDownloadJob,Error?)->Void
        ) -> HXDownloadJob
    {
        let job = HXDownloadJob(url:url, options:options, dataReady:dataReady, onQueue:readyQueue)
        
        self.serialize.async {
            if let cachedTask = self.cache.first(where:{$0.matches(job:job)}) {
                job.task = cachedTask
                cachedTask.addJob(job)
            } else if let existingTask = self.tasks.first(where:{$0.matches(job:job)}) {
                job.task = existingTask
                existingTask.addJob(job)
            } else {
                let newTask = HXDownloadTask(url:job.url, destinationURL:destinationURL)
                job.task = newTask
                newTask.addJob(job)
                self.tasks.append(newTask)
            }
            self.processQueue()
        }
        
        return job
    }
    
    public func processQueue() {
        self.serialize.async {
            for task in self.cache {
                task.sendDataReady(defaultQueue:self.delegateQueue)
            }
            
            for task in self.tasks {
                switch task.state {
                case .idle:
                    break
                case .running:
                    return
                case .paused:
                    return
                case .ready:
                    task.sendDataReady(defaultQueue:self.delegateQueue)
                    return
                case .completed:
                    task.sendDataReady(defaultQueue:self.delegateQueue)
                    return
                }
                
                if !task.hasLiveJobs() {
                    continue
                }
                
                let options = task.options
                let session = options.contains(.cellularAllowed) ? self.cellularSession : self.wifiOnlySession
                let request = URLRequest(url:task.url)
                if options.contains(.immediate) {
                    let dataTask = session.dataTask(with:request)
                    task.dataTask = dataTask
                    task.state = .running
                    dataTask.resume()
                } else {
                    let downloadTask = session.downloadTask(with:request);
                    task.downloadTask = downloadTask
                    task.state = .running
                    downloadTask.resume()
                }
            }
        }
    }
    
    private func _hxtask(_ urlSessionTask:URLSessionTask) -> HXDownloadTask {
        if let task = self.tasks.first(where: {$0.matches(urlSessionTask:urlSessionTask)}) {
            return task
        }
        fatalError("Could not find existing task for session task")
    }
    
    // MARK: - URLSessionDelegate
    public func urlSession(_ session:URLSession, didBecomeInvalidWithError error:Error?) {
        hxwarn("session became invalid!")
    }
    
    // MARK: - URLSessionTaskDelegate : URLSessionDelegate
    public func urlSession(_ session:URLSession, task:URLSessionTask, didCompleteWithError error:Error?) {
        let hxtask = self._hxtask(task)
        hxtask.error = error
        if ( error == nil ) {
            hxtask.state = .ready
            hxtask.sendDataReady(defaultQueue:self.delegateQueue)
        }
        self.tasks.removeAll(where: {$0 === hxtask})
        self.cache.append(hxtask)
        hxtask.state = .completed
    }

    // MARK: - URLSessionDataDelegate : URLSessionTaskDelegate
    public func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didBecome downloadTask: URLSessionDownloadTask) {}
    
    public func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didBecome streamTask: URLSessionStreamTask) {}

    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        let hxtask = _hxtask(dataTask)
        hxtask.appendData(data)
    }

    public func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    willCacheResponse proposedResponse: CachedURLResponse,
                    completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(nil) // to not cache the response
    }

    // MARK: - URLSessionDownloadDelegate : URLSessionTaskDelegate
    public func urlSession(_ session:URLSession, downloadTask:URLSessionDownloadTask, didFinishDownloadingTo location:URL) {
        let hxtask = self._hxtask(downloadTask)
        do {
            let destURL = hxtask.destinationURL ?? self.tempDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.moveItem(at:location, to:destURL)
            hxtask.downloadedURL = destURL
        } catch {
            hxtask.error = error
        }
        hxtask.sendDataReady(defaultQueue:self.delegateQueue)
    }
    
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64,
                    expectedTotalBytes: Int64) {}

    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {}

}
