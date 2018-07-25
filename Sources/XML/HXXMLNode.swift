// HexdreamsCocoa
// HXXMLNode.swift
// Copyright(c) 2018 Kenny Leung
// This code is PUBLIC DOMAIN

// Should probably implement some subset of XPath/XQuery
public class HXXMLNode {
    
    public weak var parent :HXXMLNode?
    public let tag         :String
    public let attributes  :[String:String]
    public var children    :[HXXMLNode]
    public var content     :String?
    public var isRoot:Bool {
        return self.parent == nil
    }
    
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
