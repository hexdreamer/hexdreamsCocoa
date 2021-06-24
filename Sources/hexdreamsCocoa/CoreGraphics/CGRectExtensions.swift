// hexdreamsCocoa
// CGRectExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

// Box drawing characters found at https://en.wikipedia.org/wiki/Box-drawing_character
// ┌  ┬  ┐
//
// ├  ┼  ┤
//
// └  ┴  ┘

import CoreGraphics

prefix operator ┌
prefix operator ┐
prefix operator └
prefix operator ┘

prefix operator ├
prefix operator ┤
prefix operator ┬
prefix operator ┴

prefix operator ┼

extension CGRect {
    static public prefix func ┌(r:CGRect) -> CGPoint {return CGPoint(x:r.minX, y:r.minY)}
    static public prefix func ┐(r:CGRect) -> CGPoint {return CGPoint(x:r.maxX, y:r.minY)}
    static public prefix func └(r:CGRect) -> CGPoint {return CGPoint(x:r.minX, y:r.maxY)}
    static public prefix func ┘(r:CGRect) -> CGPoint {return CGPoint(x:r.maxX, y:r.maxY)}
    
    static public prefix func ├(r:CGRect) -> CGPoint {return CGPoint(x:r.minX, y:r.midY)}
    static public prefix func ┤(r:CGRect) -> CGPoint {return CGPoint(x:r.maxX, y:r.midY)}
    static public prefix func ┬(r:CGRect) -> CGPoint {return CGPoint(x:r.midX, y:r.minY)}
    static public prefix func ┴(r:CGRect) -> CGPoint {return CGPoint(x:r.midX, y:r.maxY)}

    static public prefix func ┼(r:CGRect) -> CGPoint {return CGPoint(x:r.midX, y:r.midY)}

    public var aspect      :CGFloat {get{return width/height}}
    public var isPortrait  :Bool    {get{return aspect < 1  }}
    public var isLandscape :Bool    {get{return aspect > 1  }}
    public var isSquare    :Bool    {get{return aspect == 1 }}
    
    public init(size s:CGSize) {self=CGRect(x:0,y:0,width:s.width,height:s.height)}
    public init(size s:CGSize, centeredOn p:CGPoint) {self=CGRect(size:s).centerOn(point:p)}
    public init(square s:CGFloat, centeredOn p:CGPoint) {self=CGRect(x:p.x-s/2,y:p.y-s/2,width:s,height:s)}
    
    public func centerOn(point p :CGPoint) -> CGRect {return CGRect(x:p.x-width/2,y:p.y-height/2,width:width,height:height)}
    public func centerOn(rect r :CGRect) -> CGRect {return centerOn(point:┼r)}
    public func scale(_ s :CGFloat) -> CGRect {return CGRect(x:origin.x,y:origin.y,width:width*s,height:height*s)}
    public func scaleForFill(rect r :CGRect) -> CGFloat {return r.aspect<=self.aspect ? r.height/height : r.width/width}
    public func fill(rect r :CGRect) -> CGRect {return self.scale(self.scaleForFill(rect:r)).centerOn(rect:r)}
    public func scaleForFit(rect r :CGRect) -> CGFloat {return r.aspect<=self.aspect ? r.width/width : r.height/height}
    public func fit(rect r :CGRect) -> CGRect {return self.scale(self.scaleForFit(rect:r)).centerOn(rect:r)}

    /// Return a transform that fits self (centered and scaled) in outerRect
    public func tFitIn(outerRect:CGRect) -> CGAffineTransform {
        let fittedRect = self.fit(rect: outerRect)
        let scale = fittedRect.size.width/self.size.width
        let offset = CGPoint(x:fittedRect.minX, y:fittedRect.minY)
        let t = CGAffineTransform.identity
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(translationX: offset.x, y: offset.y))
        return t
    }

}

