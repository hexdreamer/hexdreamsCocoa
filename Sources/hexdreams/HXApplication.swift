// hexdreamsCocoa
// UIApplicationExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public class HXApplication {

    public class func documentsDirectory() -> URL {
        let urls = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)
        if let documentsDirectory = urls.last {
            return documentsDirectory
        }
        fatalError("Could not acquire documents directory")
    }

    public class func cachesDirectory() -> URL {
        let urls = FileManager.default.urls(for:.cachesDirectory, in:.userDomainMask)
        if let cachesDirectory = urls.last {
            return cachesDirectory
        }
        fatalError("Could not acquire cache directory")
    }
}
