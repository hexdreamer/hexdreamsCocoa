//
//  DataExtensions.swift
//  hexdreamsCocoa
//
//  Created by Kenny Leung on 2/3/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Foundation

extension Data {
    
    public func range(after prefix:Data, in searchRange:Range<Data.Index>? = nil) -> Range<Data.Index>? {
        let searchRange = searchRange ?? self.startIndex..<self.endIndex
        
        var targetIndex = prefix.startIndex
        var searchIndex = searchRange.startIndex
        while true {
            let given = prefix[targetIndex]
            let search = self[searchIndex]
            if given != search {
                return nil
            }
            targetIndex = targetIndex.advanced(by:1)
            searchIndex = searchIndex.advanced(by:1)
            if targetIndex == prefix.endIndex {
                return searchIndex..<searchRange.endIndex
            }
            if searchIndex == searchRange.endIndex {
                return nil
            }
        }
    }
}
