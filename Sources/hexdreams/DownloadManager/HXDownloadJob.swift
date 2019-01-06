//
//  HXDownloadTask.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 8/4/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

public class HXDownloadJob {
    // Have to let this one be nillable on init because we need to use this object in the URLSessionDownloadTask's creation in the completionHandler.
    let url:URL
    let options:HXDownloadManager.DownloadOptions
    let dataReady:(HXDownloadJob, Error?)->Void
    let dataReadyQueue:DispatchQueue?
    
    public weak var task:HXDownloadTask?
    var dataReadySent = false
    
    public var downloadedData:Data? {return self.task?.downloadedData}
    public var downloadedURL:URL?   {return self.task?.downloadedURL}
    public var cancelled = false

    init(url:URL, options:HXDownloadManager.DownloadOptions, dataReady:@escaping (HXDownloadJob,Error?)->Void, onQueue:DispatchQueue?) {
        self.url = url
        self.options = options
        self.dataReady = dataReady
        self.dataReadyQueue = onQueue
    }
    
    func sendDataReady(defaultQueue:DispatchQueue, error:Error?) {
        if dataReadySent {
            return
        }
        dataReadySent = true
        let queue = self.dataReadyQueue ?? defaultQueue
        queue.async {
            self.dataReady(self, error)
        }
    }
}
