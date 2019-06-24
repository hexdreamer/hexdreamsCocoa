//
//  UIViewControllerExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/24/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation
import CoreData

#if os(iOS)
import UIKit

public protocol UIViewControllerExtensions {}

extension UIViewController:UIViewControllerExtensions {}

/*
 This little trick allows us to basically add ivars and methods to HXViewController, HXTableViewController, HXCollectionViewController without duplicating the code. They just need to conform to the data-bearing protocols like HXErrorHandler, and the code here can use their ivars.
 */
public protocol UIViewControllerExtensionData:AnyObject {
    var identifier:String?                          {get set}
    var dataCache:HXCachingWrapper?                 {get set}
    var cellIdentifier:String?                      {get set}
    var selectedItem:AnyObject?                     {get set}
    
    var callback       :((UIViewController)->Void)? {get set}
    var successCallback:((UIViewController)->Void)? {get set}
    var failureCallback:((UIViewController)->Void)? {get set}
    var cancelCallback :((UIViewController)->Void)? {get set}
}

public extension UIViewControllerExtensions where Self:UIViewController, Self:UIViewControllerExtensionData, Self:HXErrorHandler {
    
    // MARK: - New Methods
    func success() {
        if let successCallback = self.successCallback {
            successCallback(self)
        } else if let callback = self.callback {
            callback(self)
        } else {
            fatalError("Neither successCallback nor callback are set")
        }
        self._clearCallbacks()
    }
    
    func failure() {
        if let failureCallback = self.failureCallback {
            failureCallback(self)
        } else if let callback = self.callback {
            callback(self)
        } else {
            fatalError("Neither failureCallback nor callback are set")
        }
        self._clearCallbacks()
    }
    
    func cancel() {
        if let cancelCallback = self.cancelCallback {
            cancelCallback(self)
        } else if let callback = self.callback {
            callback(self)
        } else {
            fatalError("Neither cancelCallback nor callback are set")
        }
        self._clearCallbacks()
    }
    
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
    
    // MARK: - Private Methods
    private func _clearCallbacks() {
        self.callback = nil
        self.successCallback = nil
        self.failureCallback = nil
        self.cancelCallback = nil
    }

}

#endif
