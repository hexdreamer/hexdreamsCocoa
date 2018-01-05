// hexdreamsCocoa
// HXObserver.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

public struct HXObserver {
    public enum Immediacy {
        case immediate
        case coalescing
        case timedcoalescing
        case uicoalescing
    }
    public static var TimedCoalescingIntervalMSDefault:UInt = 100
    public static var UICoalescingIntervalMS:UInt = 100
    public static var UICoalescingLeewayMS:UInt = 20

    
    enum NotifyingStatus {
        case waiting
        case scheduled
        case notifying
    }
}
