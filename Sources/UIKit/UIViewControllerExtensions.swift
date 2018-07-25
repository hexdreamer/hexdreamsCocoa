//
//  UIViewControllerExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/24/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*
 This little trick allows us to basically add ivars and methods to HXViewController, HXTableViewController, HXCollectionViewController without duplicating the code. They just need to conform to the data-bearing protocols like HXErrorHandler, and the code here can use their ivars.
 */

public protocol UIViewControllerExtensions {
}

public extension UIViewControllerExtensions where Self:UIViewController, Self:HXErrorHandler {
    func hxPerform(dataController:HXDataController,
                 writeActions:@escaping (NSManagedObjectContext)throws->Void,
                 readActions:@escaping (NSManagedObjectContext)throws->Void,
                 displayActions:@escaping ()throws->Void) {
        
        dataController.writeContext.perform {
            do {
                try writeActions(dataController.writeContext)
                dataController.viewContext.perform {
                    do {
                        try readActions(dataController.viewContext)
                        DispatchQueue.main.async {
                            do {
                                try displayActions()
                            } catch {
                                self.error = error
                            }
                        }
                    } catch {
                        self.error = error
                    }
                }
            } catch {
                self.error = error
            }
        }

    }
}


extension UIViewController:UIViewControllerExtensions {
    
}
