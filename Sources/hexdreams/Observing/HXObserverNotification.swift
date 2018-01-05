// hexdreamsCocoa
// HXObserverNotification.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public protocol HXObserverNotification {
    
    func contains(observed:AnyObject) -> Bool
    
}
