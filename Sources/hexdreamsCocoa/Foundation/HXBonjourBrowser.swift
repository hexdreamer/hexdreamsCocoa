// hexdreamsCocoa
// HXBonjourBrowser.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

// This is just a simple wrapper on NetServiceBrowser so you can use callbacks instead of delegate methods

import Foundation

public class HXBonjourBrowser : NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    
    let type:String
    let domain:String

    var serviceBrowser:NetServiceBrowser?
    var queue:DispatchQueue?
    var handler:((HXBonjourBrowser)->Void)?
    
    var services = [HXBonjourService]()
    
    init(type:String, domain:String) {
        self.type = type
        self.domain = domain
    }
    
    public func start(queue:DispatchQueue = DispatchQueue.main, handler:@escaping (HXBonjourBrowser)->Void) {
        self.queue = queue
        self.handler = handler

        let type = self.type
        let domain = self.domain
        let browser = NetServiceBrowser()
        browser.delegate = self
        self.serviceBrowser = browser
        DispatchQueue.main.async {
            browser.searchForServices(ofType:type, inDomain:domain)
        }
    }
    
    // MARK: - NetServiceBrowserDelegate
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        hxtrace()
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        hxtrace()
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        hxdebug(["service":service, "moreComing":moreComing])
        self.services.append(HXBonjourService(netService:service))
        if moreComing == false {
            browser.stop()
            self.queue?.async {
                self.handler?(self)
            }
        }
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        hxdebug(["service":service])
    }
    
    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        hxtrace()
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        hxtrace()
    }
    
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        hxtrace()
    }
    
}
