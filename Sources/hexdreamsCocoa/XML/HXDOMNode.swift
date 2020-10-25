//
//  HXDOMNode.swift
//  
//
//  Created by Kenny Leung on 10/24/20.
//

import Foundation
import libxml2

public struct HXDOMNode {
    
    private let wrapped:xmlNodePtr
    
    public init(_ node:xmlNodePtr) {
        self.wrapped = node
    }
        
    public var name:String {
        return self.asString(self.wrapped.pointee.name) ?? "ERROR: NO NAME"
    }
    
    public var namespace:HXXMLNamespace? {
        if let nsPtr = self.wrapped.pointee.ns {
            return HXXMLNamespace(nsPtr)
        }
        return nil
    }
        
    public var text:String? {
        var iterator = self.wrapped.pointee.children
        while let childPtr = iterator {
            defer {
                iterator = iterator?.pointee.next
            }
            if childPtr.pointee.type != XML_TEXT_NODE {
                continue
            }
            return self.asString(childPtr.pointee.content)
        }
        return nil
    }
    
    public var cdata:Data? {
        var iterator = self.wrapped.pointee.children
        while let childPtr = iterator {
            defer {
                iterator = iterator?.pointee.next
            }
            if childPtr.pointee.type != XML_CDATA_SECTION_NODE {
                continue
            }
            guard let contentPtr = childPtr.pointee.content else {
                continue
            }
            var length:Int = 0
            while contentPtr[length] != 0 {
                length += 1
            }
            return Data(bytesNoCopy:contentPtr, count:length, deallocator:.none)
        }
        return nil
    }
        
    public func attributeNamed(_ name:String) -> String? {
        return self.asString(xmlGetProp(self.wrapped, name))
    }
    
    public func childNamed(_ nsname:String) -> HXDOMNode? {
        let ns:String?
        let name:String
        if nsname.contains(":") {
            let components = nsname.split(separator:":")
            ns = String(components[0])
            name = String(components[1])
        } else {
            ns = nil
            name = nsname
        }
        
        var iterator = self.wrapped.pointee.children
        while let childPtr = iterator {
            defer {
                iterator = iterator?.pointee.next
            }
            if childPtr.pointee.type != XML_ELEMENT_NODE {
                continue
            }
            let child = HXDOMNode(childPtr)
            if ( child.name == name ) {
                if let ns = ns {
                    if let childNS = child.namespace?.prefix,
                       ns == childNS {
                        return child
                    }
                } else {
                    return child
                }
            }
        }
        
        return nil
    }
    
    public func childrenNamed(_ nsname:String) -> [HXDOMNode] {
        let ns:String?
        let name:String
        if nsname.contains(":") {
            let components = nsname.split(separator:":")
            ns = String(components[0])
            name = String(components[1])
        } else {
            ns = nil
            name = nsname
        }
        
        var children = [HXDOMNode]()
        var iterator = self.wrapped.pointee.children
        while let childPtr = iterator {
            defer {
                iterator = iterator?.pointee.next
            }
            if childPtr.pointee.type != XML_ELEMENT_NODE {
                continue
            }
            let child = HXDOMNode(childPtr)
            if ( child.name == name ) {
                if let childNS = child.namespace?.prefix,
                   childNS != ns {
                    continue
                }
                children.append(child)
            }
        }
        return children;
    }
    
    public func childNames() -> Set<String> {
        var names = Set<String>()
        var iterator = self.wrapped.pointee.children
        while let childPtr = iterator {
            defer {
                iterator = iterator?.pointee.next
            }
            if childPtr.pointee.type != XML_ELEMENT_NODE {
                continue
            }
            let child = HXDOMNode(childPtr)
            if let ns = child.namespace?.prefix {
                names.insert(ns + ":" + child.name)
            } else {
                names.insert(child.name)
            }
        }
        return names
    }

    private func asString <T> (_ ptr:UnsafePointer<T>?) -> String? {
      if let ptr = ptr {
        return String(validatingUTF8:UnsafeRawPointer(ptr).assumingMemoryBound(to:CChar.self))
      }
      return nil
    }

}
