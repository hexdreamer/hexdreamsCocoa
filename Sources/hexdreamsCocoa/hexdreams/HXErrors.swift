// hexdreamsCocoa
// HXLog.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

// 🛑

// The idea is to float a meaningful message up to the UI. Logging will take care of the rest of the information for the developer.

import Foundation

public enum HXErrors : Error {
    case unimplemented(Void?)
    case general(String)
    case invalidArgument(String)
    case hxnil(String)
    case objectNotFound(String)
    case moreThanOneObjectFound(String,[Any])
    case internalInconsistency(String)
    case network(String)
    case cocoa(String,Error?)
}

public protocol HXErrorHandler : AnyObject {
    var error:Error? {get set}
}

public extension Error {
    var hxconsoleDescription:String {
        return String(describing:self)
    }
}
