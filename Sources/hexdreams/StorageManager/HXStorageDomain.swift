// hexdreamsCocoa
// HXStorageDomain.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

extension HXStorageDomain{
    
    var path:[HXStorageDomain] {
        var stack = [HXStorageDomain]()
        var domain = self
        while true {
            stack.insert(domain, at:0)
            if let parent = domain.parent {
                domain = parent
            } else {
                break
            }
        }
        return stack
    }
    
    func adjustSize(delta:Int64) {
        self.size += delta
    }
}
