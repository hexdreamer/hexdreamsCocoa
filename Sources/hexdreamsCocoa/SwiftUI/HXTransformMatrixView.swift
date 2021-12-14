//
//  HXTransformMatrixView.swift
//
//
//  Created by Zach Young on 11/8/21.
//

import SwiftUI

struct FormattedValue {
    let strVal: String

    var integral: String = "0"
    var decimal: String = ""

    init(_ strVal: String) {
        self.strVal = strVal

        let parts: [String] = strVal.split(separator: ".").map { String($0) }
        if parts.count > 2 {
            fatalError("Split \(strVal) by '.' and got more than 2 parts!")
        }
        self.integral = parts[0]
        if parts.count > 1 {
            self.decimal = parts[1]
        }
    }
}


extension HorizontalAlignment {
    enum Integral: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }
    static let integral = HorizontalAlignment(Integral.self)
}


public struct HXTransformMatrixView: View {
    let tr: CGAffineTransform
    let title: String
    let maxSigFigs: Int
    let roundErrCutoff: CGFloat

    var formattedValues: [FormattedValue]
    var frameW: CGFloat

    public init(_ tr:CGAffineTransform, title:String = "", maxSigFigs:Int = 4, roundErrCutoff:CGFloat = 1/10e6) {
        self.tr = tr
        self.maxSigFigs = maxSigFigs < 10 ? maxSigFigs : 10
        self.roundErrCutoff = roundErrCutoff
        self.title = title

        // hack around "'self' used before all stored properties are initialized" error ...
        self.formattedValues = [FormattedValue]()
        self.frameW = 200

        // ... 'cause I really want to do this
        self.formattedValues = self.makeFormattedVals()

        let widths: [CGFloat] = [200, 213, 226, 239, 252, 265, 278, 291, 304, 317, 330]
        self.frameW = widths[self.maxSigFigs]
    }

    public var body: some View {
        HStack {
            Text("\(title)")
            HStack {
                Spacer()

                VStack(alignment: .integral) {
                    let a = formattedValues[0]
                    let c = formattedValues[2]
                    let tx = formattedValues[4]

                    formattedValueView(a)
                    formattedValueView(c)
                    formattedValueView(tx)
                }

                Spacer()

                VStack(alignment: .integral) {
                    let b = formattedValues[1]
                    let d = formattedValues[3]
                    let ty = formattedValues[5]

                    formattedValueView(b)
                    formattedValueView(d)
                    formattedValueView(ty)
                }

                Spacer()

                VStack {
                    let i0 = FormattedValue("0")
                    let i1 = FormattedValue("0")
                    let i2 = FormattedValue("1")

                    formattedValueView(i0)
                    formattedValueView(i1)
                    formattedValueView(i2)
                }
            }
            .frame(width: frameW, height: 100)
        }
    }

    func makeFormattedVals() -> [FormattedValue]  {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.usesSignificantDigits = true
        fmt.minimumSignificantDigits = 1
        fmt.maximumSignificantDigits = maxSigFigs

        let vals: [String] = [tr.a, tr.b, tr.c, tr.d, tr.tx, tr.ty]
            .map {
                let clamped = abs($0) < roundErrCutoff ? 0 : $0
                return fmt.string(for: clamped)!
            }

        return [
            FormattedValue(vals[0]),  //  a
            FormattedValue(vals[1]),  //  b
            FormattedValue(vals[2]),  //  c
            FormattedValue(vals[3]),  //  d
            FormattedValue(vals[4]),  // tx
            FormattedValue(vals[5]),  // ty
        ]
    }

    func formattedValueView(_ fm: FormattedValue) -> some View {
        return HStack {
            Text("\(fm.integral)")
                .alignmentGuide(.integral) { d in d[HorizontalAlignment.trailing]}
            if fm.decimal != "" {
                Text(".")
                Text(fm.decimal)
            } else {
                Text("")
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        let identity = CGAffineTransform.identity
        VStack(alignment: .leading) {
            HXTransformMatrixView(identity)

            let t = identity
                .scaledBy(x: 1.000003, y: 2.00000004)
                .rotated(by: 23.8)

            ForEach(0...11, id: \.self) { i in
                HXTransformMatrixView(t, title: "\(i) sig figs", maxSigFigs: i)
                    .border(Color.gray)
            }
        }
        .previewLayout(.fixed(width: 500, height: 1600))
    }
}

