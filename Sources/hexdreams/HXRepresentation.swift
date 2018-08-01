//
//  HXCache.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 5/12/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

public protocol HXRepresentation {
    
    //associatedtype RepresentedType
    
    //var representedObject:RepresentedType? {get set}
    
    // Can't use associated type for the represented object because you can't cast to a protocol with represented type (don't know why, it's a known bug)
    var representedObject:AnyObject? {get set}
}
