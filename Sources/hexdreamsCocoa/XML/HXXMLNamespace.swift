//
//  HXXMLNamespace.swift
//  
//
//  Created by Kenny Leung on 10/24/20.
//

import Foundation
import libxml2

public struct HXXMLNamespace {
    
    let wrapped:xmlNsPtr
    
    init(_ nsPtr:xmlNsPtr) {
        self.wrapped = nsPtr
    }
    
    var prefix:String? {
        return self.asString(self.wrapped.pointee.prefix)
    }
    
    private func asString <T> (_ ptr:UnsafePointer<T>?) -> String? {
      if let ptr = ptr {
        return String(validatingUTF8:UnsafeRawPointer(ptr).assumingMemoryBound(to:CChar.self))
      }
      return nil
    }

}
