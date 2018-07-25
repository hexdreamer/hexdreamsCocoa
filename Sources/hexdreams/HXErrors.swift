//
//  HXErrors.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/24/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

public enum HXErrors : Error {
    case unimplemented
    case general(String)
    case invalidArgument(String)       // message
    case objectNotFound(Any,String,String)  // our equivalent of NullPointerException args: sender, function, message
    case internalInconsistency(String)
    case network(String)
    case fatal(String)
}

public protocol HXErrorHandler:AnyObject {
    var error:Error? {get set}
}
