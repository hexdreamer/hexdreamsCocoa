//
//  HXDOMParser.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/22/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

// Look at https://github.com/cezheng/Fuzi for example of using DOM parsing from libxml2

import Foundation
import Dispatch
import libxml2

public class HXDOMParser {
    public struct ParserError : Error {
        let message:String;
        init(_ message:String) {
            self.message = message
        }
    }
        
    public enum Mode {
        case XML, HTML
    }
    
    private let mode:Mode
    public weak var delegate:HXSAXParserDelegate?
    private var xmlContext:xmlParserCtxtPtr?
    private var xmlDocPtr:xmlDocPtr?
    private var htmlContext:htmlParserCtxtPtr?
    private var htmlDocPtr:htmlDocPtr?
           
    public var element:HXDOMNode {
        return HXDOMNode(xmlDocGetRootElement(self.xmlDocPtr))
    }
    
    // MARK: Constructors/Destructors
    public init(mode:Mode) {
        self.mode = mode
    }
            
    private func _init() throws {
        if ( self.xmlContext != nil || self.htmlContext != nil ) {
            return;
        }
        switch self.mode {
            case .XML:
                guard let xmlParserCtxt = xmlCreatePushParserCtxt(nil, nil, "", 0, "") else {
                    throw ParserError("Could not create XML parser context")
                }
                self.xmlContext = xmlParserCtxt
            case .HTML:
                guard let htmlParserCtxt = xmlCreatePushParserCtxt(nil, nil, "", 0, "") else {
                    throw ParserError("Could not create HTML parser context")
                }
                self.htmlContext = htmlParserCtxt
        }
    }
    
    deinit {
        if let xmlContext = self.xmlContext {
            xmlFreeParserCtxt(xmlContext)
        }
        if let xmlDocPtr = self.xmlDocPtr {
            xmlFreeDoc(xmlDocPtr)
        }
        if let htmlContext = self.htmlContext {
            htmlFreeParserCtxt(htmlContext)
        }
        if let htmlDocPtr = self.htmlDocPtr {
            xmlFreeDoc(htmlDocPtr)
        }
    }
                            
    public func parseChunk(data:Data) throws {
        try self._init()
        data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            switch self.mode {
                case .XML:
                    xmlParseChunk(self.xmlContext, unsafePointer, Int32(data.count), 0)
                case .HTML:
                    htmlParseChunk(self.htmlContext, unsafePointer, Int32(data.count), 0)

            }
        }
    }
    
    public func finishParsing() throws {
        if let xmlContext = self.xmlContext {
            xmlParseChunk(self.xmlContext, "", 0, 1)
            let wellFormed = xmlContext.pointee.wellFormed
            if wellFormed == 0 {
                throw ParserError("XML is not well formed")
            } else {
                self.xmlDocPtr = xmlContext.pointee.myDoc
            }
        } else if let htmlContext = self.htmlContext {
            htmlParseChunk(self.htmlContext, "", 0, 1)
            let wellFormed = htmlContext.pointee.wellFormed
            if wellFormed == 0 {
                throw ParserError("HTML is not well formed")
            } else {
                self.htmlDocPtr = htmlContext.pointee.myDoc
            }
        }
    }
            
}
