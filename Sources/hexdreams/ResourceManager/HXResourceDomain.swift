//
//  HXResourceDomain.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 7/29/18.
//  Copyright © 2018 hexdreams. All rights reserved.
//

import Foundation

extension HXResourceDomain {
    
    var path:[HXResourceDomain] {
        var stack = [HXResourceDomain]()
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
