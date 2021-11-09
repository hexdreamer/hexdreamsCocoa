//
//  File.swift
//  
//
//  Created by Zach Young on 6/23/21.
//

import Foundation
import CoreGraphics.CGAffineTransform

extension CGAffineTransform {
    /// Return a transform that fits innerRect in outerRect by scaling, then centering
    static public func transformTo(fit innerRect:CGRect, in outerRect:CGRect) -> CGAffineTransform {
        let fittedRect = innerRect.fit(rect: outerRect)
        let scale = fittedRect.size.width/innerRect.size.width
        let offset = CGPoint(x:fittedRect.minX, y:fittedRect.minY)
        let t = CGAffineTransform.identity
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(translationX: offset.x, y: offset.y))
        return t
    }

    /// Return a nicely-padded table of transform values, for printing.
    /// - Parameter indent: Shift the table over to the right by prepending each line with this string; default is `""` (empty string).
    /// - Parameter maxSigFigs: Maximum number of significant figures to show for a value in the table; default is 4.
    /// - Parameter roundErrCutoff: Hide excessively small values due to Transform rounding errors; default is 1/10e6, "values less than 1 in a million show as `0`"
    public func toTable(
        indent:String = "",
        maxSigFigs:Int = 4,
        roundErrCutoff:CGFloat = 1/10e6) -> String
    {
        let t = self
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.usesSignificantDigits = true
        fmt.minimumSignificantDigits = 1
        fmt.maximumSignificantDigits = maxSigFigs

        let values:[String] = [t.a, t.b, t.c, t.d, t.tx, t.ty]
            .map {
                let clamped = abs($0) < roundErrCutoff ? 0 : $0
                return fmt.string(for: clamped)!
            }
        let maxWidth = values
            .max { (a, b) in a.count < b.count }
        let paddedValues = values
            .map { $0.hxpad(width: maxWidth!.count)}

        let a,b,c,d,tx,ty: String
         a = paddedValues[0]
         b = paddedValues[1]
         c = paddedValues[2]
         d = paddedValues[3]
        tx = paddedValues[4]
        ty = paddedValues[5]

        let row1,row2,row3: String
        row1 = indent + "┌ " +  a + " " +  b + "  0 ┐\n"
        row2 = indent + "│ " +  c + " " +  d + "  0 │\n"
        row3 = indent + "└ " + tx + " " + ty + "  1 ┘\n"

        return row1 + row2 + row3
    }
}
