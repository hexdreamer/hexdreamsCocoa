//
//  HXCollectionViewCell.swift
//  Wild-Fire
//
//  Created by Kenny Leung on 5/16/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import Foundation
import UIKit

open class HXCollectionViewCell : UICollectionViewCell,HXRepresentation {
    
    //typealias RepresentedType = T
    public var representedObject:AnyObject? {
        didSet {
            self.updateUI()
        }
    }
    
    @IBOutlet var ui1:AnyObject?
    @IBOutlet var ui2:AnyObject?
    @IBOutlet var ui3:AnyObject?
    @IBOutlet var ui4:AnyObject?
    @IBOutlet var ui5:AnyObject?
    @IBOutlet var ui6:AnyObject?
    @IBOutlet var ui7:AnyObject?
    @IBOutlet var ui8:AnyObject?
    @IBOutlet var ui9:AnyObject?
    
    func updateUI() {}
    
}

