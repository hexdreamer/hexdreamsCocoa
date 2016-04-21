// hexdreamsCocoa
// CGSizeExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

extension CGSize {
    public var aspect :CGFloat {get{return width/height}}
    public var isPortrait :Bool {get{return aspect < 1}}
    public var isLandscape :Bool {get{return aspect > 1}}
    public var isSquare :Bool {get{return aspect == 1}}
}
