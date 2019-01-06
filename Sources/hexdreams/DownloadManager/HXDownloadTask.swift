//
//  HXDownloadTask.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 12/7/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

public class HXDownloadTask : HXObject, Equatable {

    enum State {
        case idle
        case running
        case paused
        case ready
        case completed
    }
    
    let url:URL
    let destinationURL:URL?
    var state:State = .idle
    var dataTask:URLSessionDataTask?
    var downloadTask:URLSessionDownloadTask?
    var downloadedURL:URL?
    
    var options:HXDownloadManager.DownloadOptions {
        var aggregate = HXDownloadManager.DownloadOptions()
        for job in jobs {
            if job.options.contains(.cellularAllowed) {
                aggregate.insert(.cellularAllowed)
            }
            if job.options.contains(.immediate) {
                aggregate.insert(.immediate)
            }
        }
        return aggregate
    }
    
    var downloadedData:Data? {
        if self.state != .ready && self.state != .completed {
            return nil
        }
        if let data = self.accumulatingData {
            return data as Data
        }
        if let url = self.downloadedURL {
            do {
                return try NSData(contentsOf:url, options:.mappedIfSafe) as Data
            } catch {
                hxerror("Can't create NSData from \(url)")
            }
        }
        return nil
    }

    var jobs = [HXDownloadJob]()
    var error:Error?
    
    private var accumulatingData:NSMutableData?
    
    init(url:URL, destinationURL:URL?) {
        self.url = url
        self.destinationURL = destinationURL
    }
    
    func matches(job:HXDownloadJob) -> Bool {
        return self.url == job.url
    }
    
    func matches(urlSessionTask:URLSessionTask) -> Bool {
        return self.dataTask === urlSessionTask || self.downloadTask === urlSessionTask
    }
    
    func addJob(_ job:HXDownloadJob) {
        self.jobs.append(job)
    }
    
    func hasLiveJobs() -> Bool {
        if let _ = self.jobs.first(where: {$0.cancelled == false}) {
            return true
        }
        return false
    }
    
    func appendData(_ data:Data) {
        let accumulator = self.accumulatingData ?? {
            let newData = NSMutableData()
            self.accumulatingData = newData
            return newData
        }
        accumulator.append(data)
    }
    
    func sendDataReady(defaultQueue:DispatchQueue) {
        for job in self.jobs {
            job.sendDataReady(defaultQueue:defaultQueue, error:self.error)
        }
    }
    
    // MARK: - Equatable
    public static func == (lhs: HXDownloadTask, rhs: HXDownloadTask) -> Bool {
        return lhs === rhs
    }

}
