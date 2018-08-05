//
//  HXDownloadTask.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 8/4/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

class HXDownloadTask {
    // Have to let this one be nillable on init because we need to use this object in the URLSessionDownloadTask's creation in the completionHandler.
    var task:URLSessionDownloadTask?
    let options:HXDownloadManager.DownloadOptions
    var completionHandlers:[(URL?,URLResponse?,Error?)->Void]
    var completed:Bool
    
    init(options:HXDownloadManager.DownloadOptions,
         completionHandler:@escaping (URL?,URLResponse?,Error?)->Void
        ) {
        self.options = options
        self.completionHandlers = [(URL?,URLResponse?,Error?)->Void]()
        self.completed = false
        
        self.appendCompletionHandler(completionHandler)
    }
    
    func appendCompletionHandler(_ completionHandler:@escaping (URL?,URLResponse?,Error?)->Void) {
        self.completionHandlers.append(completionHandler)
    }
    
    func matches(url:URL, options:HXDownloadManager.DownloadOptions) -> Bool {
        guard let myurl = self.task?.originalRequest?.url else {
            print("This should never happen. Either task or request was nil")
            return false
        }
        return (myurl == url && self.options == options)
    }
}
