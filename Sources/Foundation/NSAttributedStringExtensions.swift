// hexdreamsCocoa
// NSAttributedStringExtensions.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

extension NSAttributedString {
    
    public class func attributesWith(font:UIFont?, color:UIColor = .black) -> [NSAttributedStringKey:Any] {
        guard let font = font else {
            fatalError("required: font")
        }
        let ctfont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attributes:[NSAttributedStringKey:Any] = [.font:ctfont, .foregroundColor:color]
        return attributes
    }
    
}

extension NSMutableAttributedString {
    
    public func hxappend(string:String, fontName:String, size:CGFloat, color:UIColor = .black) {
        guard let font = UIFont(name:fontName, size:size) else {
            fatalError("Could not find font \(fontName)")
        }
        self.hxappend(string:string, font:font, color:color)
    }
    
    public func hxappend(string:String, font:UIFont, color:UIColor = .black) {
        let attributes = type(of:self).attributesWith(font:font, color:color)
        let attributedString = NSAttributedString(string:string, attributes:attributes)
        self.append(attributedString)
    }
}
