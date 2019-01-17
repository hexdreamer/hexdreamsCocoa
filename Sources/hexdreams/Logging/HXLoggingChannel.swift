// hexdreamsCocoa
// HXLoggingChannel.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

public protocol HXLoggingChannel {
    func log(_ log:HXLog)
    func addLogs(_ logs:[HXLog])
}
