//
//  HXTableViewCell.swift
//  Wild-Fire
//
//  Created by Kenny Leung on 5/15/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

open class HXTableViewCell : UITableViewCell,HXRepresentation {
    
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
    
    func updateUI() {
        if self.representedObject is String {
            if let str = self.representedObject as? String {
                self.textLabel?.text = str;
            }
        }
    }

}

#endif
