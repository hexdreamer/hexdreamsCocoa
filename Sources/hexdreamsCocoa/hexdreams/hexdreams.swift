// hexdreamsCocoa
// hexdreams.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

#if os(OSX)
import CoreGraphics
#endif

open class HXObject : HXLoggingExtensions {
    // See HXObservingExtensions.swift for more methods
    public init() {}
}

open class HXThrowingObject : HXLoggingExtensions {
    // See HXObservingExtensions.swift for more methods
    public init() throws {}
}

public let GOLDEN_RATIO = CGFloat(1.61803398875)

