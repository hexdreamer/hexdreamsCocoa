// hexdreamsCocoa
// HXBonjourService.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXBonjourService : NSObject, NetServiceDelegate {
    
    let netService:NetService
    var queue:DispatchQueue?
    var handler:((HXBonjourService)->Void)?
    
    init(netService:NetService) {
        self.netService = netService
    }
    
    func resolve(queue:DispatchQueue = DispatchQueue.main, handler:@escaping (HXBonjourService)->Void) {
        self.queue = queue
        self.handler = handler
        
        // We always use the main queue to resolve because a run loop is required to work properly
        self.netService.delegate = self
        DispatchQueue.main.async {
            self.netService.resolve(withTimeout:5)
        }
    }
    
    // MARK: - NetServiceDelegate
    public func netServiceWillPublish(_ sender: NetService) {
        hxtrace()
    }
    
    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        hxtrace()
    }
    
    public func netServiceDidPublish(_ sender: NetService) {
        hxtrace()
    }
    
    public func netServiceWillResolve(_ sender: NetService) {
        hxtrace()
    }
    
    public func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        hxtrace()
    }
    
    public func netServiceDidResolveAddress(_ sender: NetService) {
        hxdebug(["service":sender, "hostname":sender.hostName, "port":sender.port])
        self.queue?.async {
            self.handler?(self)
        }
    }
    
    public func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        hxtrace()
    }
    
    public func netServiceDidStop(_ sender: NetService) {
        hxtrace()
    }
    
    public func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        hxtrace()
    }
    
}
