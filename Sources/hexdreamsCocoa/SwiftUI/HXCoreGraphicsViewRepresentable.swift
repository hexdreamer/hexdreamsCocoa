//
//  File.swift
//  
//
//  Created by Kenny Leung on 10/31/20.
//

import Foundation
import SwiftUI

public struct HXCoreGraphicsViewRepresentable: UIViewRepresentable {
        
    var coreGraphicsCommands:(CGContext,CGRect)->Void
    
    public init(_ cgCommands:@escaping (CGContext,CGRect)->Void) {
        self.coreGraphicsCommands = cgCommands
    }

    public func makeUIView(context: Context) -> HXCoreGraphicsView {
        return HXCoreGraphicsView(self.coreGraphicsCommands)
    }

    public func updateUIView(_ uiView: HXCoreGraphicsView, context: Context) {
        // do nothing
    }
}

public class HXCoreGraphicsView : UIView {
    
    var coreGraphicsCommands: ((CGContext,CGRect)->Void)?
        
    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    
    convenience init(_ cgCommands:@escaping(CGContext,CGRect)->Void) {
        self.init(frame:CGRect.zero)
        self.coreGraphicsCommands = cgCommands
    }
    
    public override func draw(_ rect: CGRect) {
        if let cgCommands = self.coreGraphicsCommands,
           let ctx = UIGraphicsGetCurrentContext() {
            cgCommands(ctx, rect)
        }
    }
}
