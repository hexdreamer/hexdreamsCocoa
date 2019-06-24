// hexdreamsCocoa
// UIApplicationExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public class HXApp {

    #if os(macOS)
    public static var shared:NSApplication {
        return NSApplication.shared
    }
    #elseif os(iOS)
    public static var shared:UIApplication {
        return UIApplication.shared
    }
    #endif

    #if os(macOS)
    public static var delegate:NSApplicationDelegate {
        if let delegate = NSApplication.shared.delegate {
            return delegate
        }
        fatalError("Application delegate is nil")
    }
    #elseif os(iOS)
    public static var delegate:UIApplicationDelegate {
        if let delegate = UIApplication.shared.delegate {
            return delegate
        }
        fatalError("Application delegate is nil")
    }
    #endif

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
