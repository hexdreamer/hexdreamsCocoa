// HexdreamsCocoa
// HXXMLParser.swift
// Copyright(c) 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public class HXXMLParser: NSObject, XMLParserDelegate {
    
    var rootNode    :HXXMLNode?
    var currentNode :HXXMLNode?

    public func parse(data:Data) -> HXXMLNode? {
        let parser = XMLParser(data:data);
        
        parser.delegate = self
        if ( parser.parse() ) {
            return rootNode;
        }
        return nil
    }

    public func parser(_ parser:XMLParser, didStartElement elementName:String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict:[String:String]) {
        if self.rootNode == nil {
            self.rootNode = HXXMLNode(parent:nil, tag:elementName, attributes:attributeDict)
            self.currentNode = self.rootNode
        } else {
            guard let tailNode = self.currentNode else {
                return  // error
            }
            let node = HXXMLNode(parent: tailNode, tag: elementName, attributes: attributeDict)
            tailNode.children.append(node)
            self.currentNode = node
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let tailNode = self.currentNode else {
            return  // error
        }
        if let content = tailNode.content,
            !content.isEmpty {
            tailNode.content = content.trimmingCharacters(in:.whitespacesAndNewlines)
        }
        self.currentNode = tailNode.parent
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let tailNode = self.currentNode else {
            return // error
        }
        if let content = tailNode.content {
            tailNode.content = content + string
        } else {
            tailNode.content = string
        }
    }

}

