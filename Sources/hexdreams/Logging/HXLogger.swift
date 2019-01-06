//
//  HXLogger.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 1/2/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Foundation

public class HXLogger {
    
    static private let serialize = DispatchQueue(label:"HXLogger", qos:.default, attributes:[], autoreleaseFrequency:.workItem, target:nil)

    static let shared = HXLogger()
    
    private var channels = [HXLoggingChannel]()
    
    init() {
        let channel = HXFileHandleLoggingChannel(filehandle:FileHandle.standardError)
        self.channels.append(channel)
    }
    
    // This is the master log function. Everyone else winds up calling this.
    public func log(
        level:HXLog.Level,
        function:String, file:String, line:Int,
        callStackReturnAddresses:[NSNumber],
        callingType:Any.Type? = nil, callingInstance:AnyObject? = nil,
        message:String? = nil, variables:[String:Any?]? = nil,
        messageTime:TimeInterval? = nil, measureTime:TimeInterval? = nil,
        threadVariables:[String:Any?]?, typeVariables:[String:Any?]?, instanceVariables:[String:Any?]?
        )
    {
        let thread = Thread.current
        let log = HXLog(timestamp:Date(),
                        threadIdentifier:Unmanaged.passUnretained(thread).toOpaque(), threadName:thread.isMainThread ? "main" : thread.name,
                        level:level,
                        function:function, file:file, line:line,
                        callStackReturnAddresses:callStackReturnAddresses,
                        callingType:callingType.flatMap{"\($0)"}, callingInstance:Unmanaged.passUnretained(thread).toOpaque(),
                        message:message, variables:variables,
                        messageTime:messageTime, measureTime:measureTime,
                        threadVariables:threadVariables, typeVariables:typeVariables, instanceVariables:instanceVariables)
        HXLogger.serialize.async {
            for channel in self.channels {
                channel.log(log)
            }
        }
    }
    

}
