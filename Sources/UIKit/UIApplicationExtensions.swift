// hexdreamsCocoa
// UIApplicationExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit

extension UIApplication {

    public class func applicationDocumentsDirectory() -> NSURL {
        let urls = NSFileManager.default().urlsForDirectory(NSSearchPathDirectory.documentDirectory, inDomains: NSSearchPathDomainMask.userDomainMask)
        if let documentsDirectory = urls.last {
            return documentsDirectory
        }
        fatalError("Could not acquire documents directory")
    }

}
