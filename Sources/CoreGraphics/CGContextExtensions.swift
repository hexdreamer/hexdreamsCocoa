// hexdreamsCocoa
// CGContextExtensions.swift
// Copyright © 2017 Kenny Leung
// This code is PUBLIC DOMAIN

extension CGContext {
    
    // ┌  ┬  ┐
    //
    // ├  ┼  ┤
    //
    // └  ┴  ┘

    public func addRoundedRect(in r:CGRect, cornerRadius:CGFloat) {
        self.move(to: ├r)
        
        self.addArc(tangent1End: ┌r, tangent2End: ┬r, radius:cornerRadius)
        
        self.addArc(tangent1End: ┐r, tangent2End: ┤r, radius:cornerRadius)
        
        self.addArc(tangent1End: ┘r, tangent2End: ┴r, radius:cornerRadius)
        
        self.addArc(tangent1End: └r, tangent2End: ├r, radius:cornerRadius)
        
        self.closePath()
    }
    
}
