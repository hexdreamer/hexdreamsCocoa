// hexdreamsCocoa
// UIApplicationExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit

extension UIApplication {

    public class func applicationDocumentsDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        if let documentsDirectory = urls.last {
            return documentsDirectory
        }
        fatalError("Could not acquire documents directory")
    }

}
