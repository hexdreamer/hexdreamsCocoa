//
//  HXTransformMatrixView.swift
//  
//
//  Created by Zach Young on 11/8/21.
//

import SwiftUI

struct FormattedValue: Identifiable {
    let id = UUID()
    let name: String
    let strVal: String

    var integral: String = "0"
    var decimal: String = ""

    init(name: String, strVal: String) {
        self.name = name
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
    let maxSigFigs: Int
    let roundErrCutoff: CGFloat

    public init(_ tr:CGAffineTransform, maxSigFigs:Int = 4, roundErrCutoff:CGFloat = 1/10e6) {
        self.tr = tr
        self.maxSigFigs = maxSigFigs
        self.roundErrCutoff = roundErrCutoff
    }

    var formattedValues: [FormattedValue] {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.usesSignificantDigits = true
        fmt.minimumSignificantDigits = 1
        fmt.maximumSignificantDigits = maxSigFigs

        let vals: [String] = [tr.a, tr.b, tr.c, tr.d, tr.tx, tr.ty]
            .map {
                let clamped = abs($0) < roundErrCutoff ? 0 : $0
                print(clamped)
                return fmt.string(for: clamped)!
            }

        return [
            FormattedValue(name: "a", strVal: vals[0]),
            FormattedValue(name: "b", strVal: vals[1]),
            FormattedValue(name: "c", strVal: vals[2]),
            FormattedValue(name: "d", strVal: vals[3]),
            FormattedValue(name: "tx", strVal: vals[4]),
            FormattedValue(name: "ty", strVal: vals[5]),
        ]
    }

    public var body: some View {
        HStack {
            Spacer()

            VStack(alignment: .integral) {
                let a = formattedValues[0]
                let c = formattedValues[2]
                let tx = formattedValues[4]

                formattedValue(a)
                formattedValue(c)
                formattedValue(tx)
            }

            Spacer()

            VStack(alignment: .integral) {
                let b = formattedValues[1]
                let d = formattedValues[3]
                let ty = formattedValues[5]

                formattedValue(b)
                formattedValue(d)
                formattedValue(ty)
            }

            Spacer()

            VStack(alignment: .integral) {
                let i0 = FormattedValue(name: "i0", strVal: "0")
                let i1 = FormattedValue(name: "i1", strVal: "0")
                let i2 = FormattedValue(name: "i2", strVal: "1")

                formattedValue(i0)
                formattedValue(i1)
                formattedValue(i2)
            }

            Spacer()

        }
        .frame(width: 230, height: 100)
    }

    func formattedValue(_ fm: FormattedValue) -> some View {
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
        VStack {
            Spacer()
            HXTransformMatrixView(identity)
            Spacer()
            HXTransformMatrixView(identity
                                    .scaledBy(x: 1.3, y: 2.4)
                                    .rotated(by: 23.8)
            )
            Spacer()
            HXTransformMatrixView(identity
                                    .translatedBy(x: 100, y: 201.18)
                                    .scaledBy(x: 0.4, y: 0.003)
                                  )
            Spacer()
        }
    }
}
