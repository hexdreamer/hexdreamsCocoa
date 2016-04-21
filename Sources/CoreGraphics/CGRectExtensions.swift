// hexdreamsCocoa
// CGRectExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

extension CGRect {
    public var aspect :CGFloat {get{return width/height}}
    public var isPortrait :Bool {get{return aspect < 1}}
    public var isLandscape :Bool {get{return aspect > 1}}
    public var isSquare :Bool {get{return aspect == 1}}
    public var center :CGPoint {get{return CGPointMake(midX,midY)}}
    
    public init(size s:CGSize) {self=CGRectMake(0,0,s.width,s.height)}
    public init(size s:CGSize, centeredOn p:CGPoint) {self=CGRect(size:s).centerOn(p)}
    public init(square s:CGFloat, centeredOn p:CGPoint) {self=CGRectMake(p.x-s/2,p.y-s/2,s,s)}
    
    public func centerOn(p :CGPoint) -> CGRect {return CGRectMake(p.x-width/2,p.y-height/2,width,height)}
    public func centerOn(r :CGRect) -> CGRect {return centerOn(r.center)}
    public func scale(s :CGFloat) -> CGRect {return CGRectMake(origin.x,origin.y,width*s,height*s)}
    public func scaleAround(r :CGRect) -> CGFloat {return r.aspect<=self.aspect ? r.height/height : r.width/width}
    public func scaleAndCenterAround(r :CGRect) -> CGRect {return self.scale(self.scaleAround(r)).centerOn(r)}
    public func scaleIn(r :CGRect) -> CGFloat {return r.aspect<=self.aspect ? r.width/width : r.height/height}
    public func scaleAndCenterIn(r :CGRect) -> CGRect {return self.scale(self.scaleIn(r)).centerOn(r)}
}
