// hexdreamsCocoa
// CGPointExtensions.swift
// Copyright © 2017 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreGraphics

infix operator →
infix operator ←
infix operator ↑
infix operator ↓

extension CGPoint {

    static public func →(p:CGPoint, o:CGFloat) -> CGPoint {return CGPoint(x:p.x + o, y:p.y)}
    static public func ←(p:CGPoint, o:CGFloat) -> CGPoint {return CGPoint(x:p.x - o, y:p.y)}
    static public func ↑(p:CGPoint, o:CGFloat) -> CGPoint {return CGPoint(x:p.x, y:p.y - o)}
    static public func ↓(p:CGPoint, o:CGFloat) -> CGPoint {return CGPoint(x:p.x, y:p.y + o)}

}
