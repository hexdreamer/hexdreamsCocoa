//
//  HXModelObject.swift
//  Wild-Fire
//
//  Created by Kenny Leung on 5/15/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import Foundation

public protocol HXModelObject {
    
    // Corresponds to textLabel and detailTextLabel for auto-display in table cells
    var text:String? {get}
    var detailText:String? {get}
    
}
