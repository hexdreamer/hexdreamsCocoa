// HexdreamsCocoa
// HXXMLNode.swift
// Copyright(c) 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public class HXXMLNode {
    
    weak var parent :HXXMLNode?
    public let tag  :String
    let attributes  :[String:String]
    var children    :[HXXMLNode]
    var content     :String?
    
    init(parent:HXXMLNode?, tag:String, attributes:[String:String]) {
        self.parent = parent
        self.tag = tag
        self.attributes = attributes
        self.children = [HXXMLNode]()
    }
    
    public func deepDescription() -> String {
        return self.deepDescription(level: 0)
    }
    
    private func deepDescription(level:Int) -> String {
        var desc = ""

        for _ in 0..<level {
            desc += "   "
        }
        
        desc += tag
        if let content = self.content,
            !content.isEmpty {
            desc += ": "
            desc += content
        }
        desc += "\n"
        for childNode in children {
            desc += childNode.deepDescription(level:level + 1)
        }
        return desc
    }
}
