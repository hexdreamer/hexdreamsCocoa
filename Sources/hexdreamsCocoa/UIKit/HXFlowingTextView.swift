// hexdreamsCocoa
// HXFlowingTextView.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import CoreText
import CoreGraphics

#if os(iOS)
import UIKit

public class HXFlowingTextView : UIView {
    
    public var text:NSAttributedString?
    public var textMargins:UIEdgeInsets = UIEdgeInsets(top:0, left:0, bottom:0, right:0)
    public var flowMargins:UIEdgeInsets = UIEdgeInsets(top:0, left:0, bottom:0, right:0)
    public var maximumHeight:CGFloat = 500
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        hxdebug(["bounds":self.bounds])

        var margins = self.textMargins
        margins.top = 0
        margins.bottom = self.textMargins.top
        let bounds = self.bounds
        let boundingBox = bounds.inset(by:margins)
        guard let c = UIGraphicsGetCurrentContext(),
            let frame = self._createCTFrame(boundingBox:boundingBox) else {
                return
        }
        
        c.translateBy(x:0, y:bounds.maxY)
        c.scaleBy(x:1.0, y:-1.0)
        CTFrameDraw(frame, c);
        
        hxdraw("drawing borders and baselines") {
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
            let attributes = NSAttributedString.attributesWith(font:UIFont(name:"AvenirNextCondensed-Bold", size:8), color:.orange)
            for lineOrigin in lineOrigins {
                c.strokeLineSegments(between:[CGPoint(x:boundingBox.minX, y:lineOrigin.y), CGPoint(x:boundingBox.maxX, y:lineOrigin.y)])
                
                let lineLabel = NSAttributedString(string:"\(Int(lineOrigin.y))", attributes:attributes)
                let line = CTLineCreateWithAttributedString(lineLabel)
                let offset = CGFloat(CTLineGetPenOffsetForFlush(line, 1.0, 50))
                c.textPosition = CGPoint(x:boundingBox.maxX - 52 + offset, y:lineOrigin.y + 1)
                CTLineDraw(line, c)
            }
        }
    }
    
    override public func sizeToFit() {
        hxdebug(["bounds":self.bounds])

        var boundingBox = self.bounds
        boundingBox = boundingBox.inset(by:self.textMargins)
        boundingBox.size.height = self.maximumHeight
        guard let frame = self._createCTFrame(boundingBox:boundingBox) else {
            return
        }
        
        let lines = CTFrameGetLines(frame)
        let count = CFArrayGetCount(lines)
        var lineOrigins = [CGPoint](repeating:.zero, count:1)
        CTFrameGetLineOrigins(frame, CFRange(location:count - 1, length:1), &lineOrigins);
        let lastLineOrigin = lineOrigins[0];
        
        var fitFrame = self.frame
        fitFrame.size.height = (boundingBox.maxY - lastLineOrigin.y) + self.textMargins.top + self.textMargins.bottom
        if ( fitFrame != self.frame ) {
            self.frame = fitFrame
            self.setNeedsDisplay()
        }
    }
    
    private func _createCTFrame(boundingBox:CGRect) -> CTFrame? {
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
            flowRect = flowRect.inset(by:self.flowMargins)
            let clippingPath = CGPath(rect:flowRect, transform:&transform)
            clippingPaths.append([kCTFramePathClippingPathAttributeName:clippingPath] as CFDictionary)
        }
        return CTFramesetterCreateFrame(framesetter, CFRange(location:0, length:text.length), boundingPath, [kCTFrameClippingPathsAttributeName:clippingPaths as CFArray] as CFDictionary)
    }
}

#endif
