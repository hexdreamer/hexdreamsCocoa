// hexdreamsCocoa
// UIApplicationExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
import UIKit

public class HXApp {

    public static var shared:UIApplication {
        return UIApplication.shared
    }
    
    public static var delegate:UIApplicationDelegate {
        if let delegate = UIApplication.shared.delegate {
            return delegate
        }
        fatalError("Application delegate is nil")
    }
    
    public static var documentsDirectory:URL = {
        let urls = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)
        if let documentsDirectory = urls.last {
            return documentsDirectory
        }
        fatalError("Could not acquire documents directory")
    }()

    public static var cachesDirectory:URL = {
        let urls = FileManager.default.urls(for:.cachesDirectory, in:.userDomainMask)
        if let cachesDirectory = urls.last {
            return cachesDirectory
        }
        fatalError("Could not acquire cache directory")
    }()
    
}
