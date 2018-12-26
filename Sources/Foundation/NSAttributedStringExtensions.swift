// hexdreamsCocoa
// NSAttributedStringExtensions.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

extension NSMutableAttributedString {
    
    public func hxappend(string:String, fontName:String, size:CGFloat, color:UIColor = .black) {
        guard let font = UIFont(name:fontName, size:size) else {
            fatalError("Could not find font \(fontName)")
        }
        self.hxappend(string:string, font:font, color:color)
    }
    
    public func hxappend(string:String, font:UIFont, color:UIColor = .black) {
        let ctfont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        var attributes = [NSAttributedStringKey:Any]()
        attributes[.font] = ctfont
        attributes[.foregroundColor] = color.cgColor
        let attributedString = NSAttributedString(string:string, attributes:attributes)
        self.append(attributedString)
    }
}
