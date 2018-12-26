// hexdreamsCocoa
// HXFlowingTextView.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit
import CoreText
import CoreGraphics

public class HXFlowingTextView : UIView {
    
    public var text:NSAttributedString?
    public var textMargins:UIEdgeInsets = UIEdgeInsets(top:0, left:0, bottom:0, right:0)
    public var flowMargins:UIEdgeInsets = UIEdgeInsets(top:0, left:0, bottom:0, right:0)
    public var maximumHeight:CGFloat = 500
    public var debug = false
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        var margins = self.textMargins
        margins.top = 0
        margins.bottom = self.textMargins.top
        let bounds = self.bounds
        let boundingBox = UIEdgeInsetsInsetRect(bounds, margins)
        guard let c = UIGraphicsGetCurrentContext(),
            let frame = self._generateCTFrame(boundingBox:boundingBox) else {
                return
        }
        
        c.translateBy(x:0, y:bounds.maxY)
        c.scaleBy(x:1.0, y:-1.0)
        CTFrameDraw(frame, c);
        
        if ( debug ) {
            c.setLineWidth(1.0)
            c.setStrokeColor(UIColor.red.cgColor)
            c.stroke(self.bounds)
            c.stroke(boundingBox)
            
            let lines = CTFrameGetLines(frame)
            let count = CFArrayGetCount(lines)
            var lineOrigins = [CGPoint](repeating:.zero, count:count)
            CTFrameGetLineOrigins(frame, CFRange(location:0, length:count), &lineOrigins);
            c.setLineWidth(0.5)
            c.setStrokeColor(UIColor.orange.cgColor)
            for lineOrigin in lineOrigins {
                c.strokeLineSegments(between:[CGPoint(x:boundingBox.minX, y:lineOrigin.y), CGPoint(x:boundingBox.maxX, y:lineOrigin.y)])
            }
        }
    }
    
    override public func sizeToFit() {
        var boundingBox = self.bounds
        boundingBox = UIEdgeInsetsInsetRect(boundingBox, self.textMargins)
        boundingBox.size.height = self.maximumHeight
        guard let frame = self._generateCTFrame(boundingBox:boundingBox) else {
            return
        }
        
        let lines = CTFrameGetLines(frame)
        let count = CFArrayGetCount(lines)
        var lineOrigins = [CGPoint](repeating:.zero, count:1)
        CTFrameGetLineOrigins(frame, CFRange(location:count - 1, length:1), &lineOrigins);
        let lastLineOrigin = lineOrigins[0];
        
        var fitFrame = self.frame
        fitFrame.size.height = (boundingBox.maxY - lastLineOrigin.y) + self.textMargins.top + self.textMargins.bottom
        self.frame = fitFrame
    }
    
    private func _generateCTFrame(boundingBox:CGRect) -> CTFrame? {
        guard let text = self.text else {
            return nil
        }
        
        var identity = CGAffineTransform.identity
        
        let boundingPath = CGPath(rect:boundingBox, transform:&identity)
        let framesetter = CTFramesetterCreateWithAttributedString(text)
        
        var clippingPaths = [CFDictionary]()
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x:0, y:boundingBox.maxY)
        transform = transform.scaledBy(x:1.0, y:-1.0)
        for subview in self.subviews {
            var flowRect = subview.frame;
            flowRect = UIEdgeInsetsInsetRect(flowRect, self.flowMargins);
            let clippingPath = CGPath(rect:flowRect, transform:&transform)
            clippingPaths.append([kCTFramePathClippingPathAttributeName:clippingPath] as CFDictionary)
        }
        return CTFramesetterCreateFrame(framesetter, CFRange(location:0, length:text.length), boundingPath, [kCTFrameClippingPathsAttributeName:clippingPaths as CFArray] as CFDictionary)
    }
}
