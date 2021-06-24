//
//  File.swift
//  
//
//  Created by Zach Young on 6/23/21.
//

import Foundation
import CoreGraphics.CGAffineTransform

/// https://stackoverflow.com/a/39215372/246801
extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            let pad = String(repeatElement(character, count: toLength - stringLength))
            return pad + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

extension CGAffineTransform {
    func print() -> Void {
        let t = self
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumSignificantDigits = 4

        let values = [t.a, t.b, t.c, t.d, t.tx, t.ty]
            .map { fmt.string(for: $0)! }
        let max = values.max { (a, b) in a.count < b.count }!.count
        let paddedValues = values
            .map { $0.leftPadding(toLength: max, withPad: " ")}

        var a,b,c,d,tx,ty: String
        a = paddedValues[0]
        b = paddedValues[1]
        c = paddedValues[2]
        d = paddedValues[3]
        tx = paddedValues[4]
        ty = paddedValues[5]

        let s = "┌ \(a) \(b)  0 ┐\n" + "│ \(c) \(d)  0 │\n" + "└ \(tx) \(ty)  1 ┘\n"
        Swift.print(s)
    }
}
