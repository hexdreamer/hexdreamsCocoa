// hexdreamsCocoa
// HXLoggingCovers.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

func hxloggingIsEnabled(level:HXLog.Level) -> Bool {
    return true
}

var hxThreadVariables:[String:Any?]? {
    return nil
}

var hxTypeVariables:[String:Any?]? {
    return nil
}

var hxInstanceVariables:[String:Any?]? {
    return nil
}

func hxlog(
    level:HXLog.Level,
    function:String, file:String, line:Int,
    callStackReturnAddresses:[NSNumber],
    message:String? = nil, variables:[String:Any?]? = nil, error:Error? = nil,
    messageTime:TimeInterval? = nil, measureTime:TimeInterval? = nil
    ) {
    let thread = Thread.current
    let threadContext = HXThreadContext.context(for:thread)
    HXLogger.shared.log(level:level,
                        function:function, file:file, line:line,
                        callStackReturnAddresses:callStackReturnAddresses,
                        callingType:nil, callingInstance:nil,
                        message:message, variables:variables, error:error,
                        messageTime:messageTime, measureTime:measureTime,
                        threadVariables:threadContext.threadVariables,
                        typeVariables:nil,
                        instanceVariables:nil)
}

public func hxtrace(
    _ messageClosure:() throws -> String?,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) rethrows
{
    if !hxloggingIsEnabled(level:.trace) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    
    hxlog(level:.trace,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables,
          messageTime:messageTime)
}

public func hxtrace(
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    )
{
    if !hxloggingIsEnabled(level:.trace) {
        return
    }
    
    hxlog(level:.trace,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          variables:variables)
}

public func hxdebug(
    _ messageClosure:@autoclosure () throws -> String?,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) rethrows
{
    if !hxloggingIsEnabled(level:.debug) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    
    hxlog(level:.debug,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables,
          messageTime:messageTime)
}

public func hxdebug(
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    )
{
    if !hxloggingIsEnabled(level:.debug) {
        return
    }
    
    hxlog(level:.debug,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          variables:variables)
}

public func hxdebug(
    _ messageClosure:@autoclosure () throws -> String?,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses,
    _ performClosure:() throws -> Void
    ) rethrows
{
    if !hxloggingIsEnabled(level:.debug) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    let measureStart = Date.timeIntervalSinceReferenceDate
    try performClosure()
    let measureTime = Date.timeIntervalSinceReferenceDate - measureStart
    
    hxlog(level:.debug,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables,
          messageTime:messageTime, measureTime:measureTime)
}

public func hxinfo(
    _ messageClosure:@autoclosure () throws -> String?,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) rethrows
{
    if !hxloggingIsEnabled(level:.info) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    
    hxlog(level:.info,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables,
          messageTime:messageTime)
}

public func hxwarn(
    _ messageClosure:@autoclosure () throws -> String?,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) rethrows
{
    if !hxloggingIsEnabled(level:.warn) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    
    hxlog(level:.warn,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables,
          messageTime:messageTime)
}

func hxcaught(
    _ error:Error,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    )
{
    if hxloggingIsEnabled(level:.caught) {
        hxlog(level:.caught,
              function:function, file:file, line:line,
              callStackReturnAddresses:callStackReturnAddresses,
              message:nil, variables:nil, error:error)
    }
}

func hxthrown(
    _ error:HXErrors,
    _ message:String? = nil,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) -> HXErrors
{
    if hxloggingIsEnabled(level:.thrown) {
        hxlog(level:.thrown,
              function:function, file:file, line:line,
              callStackReturnAddresses:callStackReturnAddresses,
              message:message, variables:variables, error:error)
    }
    return error
}

func hxthrown(
    _ error:Error,
    _ message:String? = nil,
    _ variables:[String:Any?]? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) -> Error
{
    if hxloggingIsEnabled(level:.thrown) {
        hxlog(level:.thrown,
              function:function, file:file, line:line,
              callStackReturnAddresses:callStackReturnAddresses,
              message:message, variables:variables, error:error)
    }
    return error
}

public func hxerror(
    _ messageClosure:@autoclosure () throws -> String?,
    _ variables:[String:Any?]? = nil,
    _ error:Error? = nil,
    function:String = #function, file:String = #file, line:Int = #line,
    callStackReturnAddresses:[NSNumber] = Thread.callStackReturnAddresses
    ) rethrows
{
    if !hxloggingIsEnabled(level:.error) {
        return
    }
    
    let messageStart = Date.timeIntervalSinceReferenceDate
    let message = try messageClosure()
    let messageTime = Date.timeIntervalSinceReferenceDate - messageStart
    
    hxlog(level:.error,
          function:function, file:file, line:line,
          callStackReturnAddresses:callStackReturnAddresses,
          message:message, variables:variables, error:error,
          messageTime:messageTime)
}
