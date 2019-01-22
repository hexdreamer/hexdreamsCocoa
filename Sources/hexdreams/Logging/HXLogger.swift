// hexdreamsCocoa
// HXLogger.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXLogger : HXObject {
    public static var networkLoggingDisabled = false
    public static let shared = HXLogger()

    private let serialize = DispatchQueue(label:"HXLogger", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    
    private let stderrChannel = HXFileHandleLoggingChannel(filehandle:FileHandle.standardError)
    private var networkChannel:HXNetworkLoggingChannel? = nil
    private var activeChannel:HXLoggingChannel
    var logs = [HXLog]()
    var initializing = true
    var bonjourBrowser:HXBonjourBrowser? = nil
    
    private override init() {
        self.activeChannel = self.stderrChannel
        
        if HXLogger.networkLoggingDisabled {
            self.initializing = false
            super.init()
            return
        }
        
        let bonjourBrowser = HXBonjourBrowser(type:"_hxlogging._tcp.", domain:"");
        self.bonjourBrowser = bonjourBrowser
        super.init()
        bonjourBrowser.start(queue:self.serialize) {
            if $0.services.count > 1 {
                self.hxwarn("Found more than one destination to log to. Ignoring.")
            }
            $0.services[0].resolve(queue:self.serialize) {
                guard let hostname = $0.netService.hostName else {
                    self.hxwarn("could not resolve hostname. Ignoring.")
                    return
                }
                let port = $0.netService.port
                guard port > 0 else {
                    self.hxwarn("could not resolve port. Ignoring.")
                    return
                }
                self.hxinfo("Switching over to Dreamsight on \(hostname):\(port)")
                self.serialize.async {
                    let channel = HXNetworkLoggingChannel(hostname:hostname, port:port)
                    channel.addLogs(self.logs)
                    self.networkChannel = channel
                    self.activeChannel = channel
                    self.logs.removeAll()
                    self.initializing = false
                    self.bonjourBrowser = nil
                }
            }
        }
    }
    
    // This is the master log function. Everyone else winds up calling this.
    public func log(
        level:HXLog.Level,
        function:String, file:String, line:Int,
        callStackReturnAddresses:[NSNumber],
        callingType:Any.Type? = nil, callingInstance:AnyObject? = nil,
        message:String? = nil, variables:[String:Any?]? = nil, error:Error? = nil,
        messageTime:TimeInterval? = nil, measureTime:TimeInterval? = nil,
        threadVariables:[String:Any?]?, typeVariables:[String:Any?]?, instanceVariables:[String:Any?]?
        )
    {
        let thread = Thread.current
        let log = HXLog(timestamp:HXTimestamp(),
                        threadIdentifier:"\(Unmanaged.passUnretained(thread).toOpaque())", threadName:thread.isMainThread ? "main" : thread.name,
                        level:level,
                        function:function, file:file, line:line,
                        callStackReturnAddresses:callStackReturnAddresses,
                        callingType:callingType.flatMap{"\($0)"}, callingInstance:"\(Unmanaged.passUnretained(thread).toOpaque())",
                        message:message, variables:variables, error:error,
                        messageTime:messageTime, measureTime:measureTime,
                        threadVariables:threadVariables, typeVariables:typeVariables, instanceVariables:instanceVariables)
        self.serialize.async {
            if self.initializing {
                self.logs.append(log)
            }
            self.activeChannel.log(log)
        }
    }

}
