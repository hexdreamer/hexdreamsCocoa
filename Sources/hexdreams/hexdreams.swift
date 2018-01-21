// hexdreamsCocoa
// hexdreams.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public enum HXErrors : Error {
    case invalidArgument(String)       // message
    case objectNotFound(Any,String,String)  // our equivalent of NullPointerException args: sender, function, message
    case internalInconsistency(String)
    case fatal(String)
}

open class HXObject {
    // See HXObservingExtensions.swift for more methods
    public init() {}
}

open class HXThrowingObject {
    // See HXObservingExtensions.swift for more methods
    public init() throws {}
}
