//
//  File.swift
//  
//
//  Created by Kenny Leung on 2/18/20.
//

import Foundation

public extension Sequence {

    func hxjoin(
        _ delimiter      :String,
        _ mapFunction    :(Element)->Any?
    ) -> String
    {
        return self.hxjoin(nil, delimiter, nil, mapFunction)
    }

    func hxjoin(
        _ startDelimiter :String? = nil,
        _ delimiter      :String,
        _ endDelimiter   :String? = nil,
        _ mapFunction    :(Element)->Any?
    ) -> String
    {
        var buffer = ""
        var hasValue = false
        for element in self {
            if let value = mapFunction(element) {
                let valueString = String(describing:value)
                if !valueString.isEmpty {
                    if !hasValue {
                        hasValue = true
                        if let startDelimiter = startDelimiter {
                            buffer.append(startDelimiter)
                        }
                    } else {
                        buffer.append(delimiter)
                    }
                    buffer.append(String(describing:value))
                }
            }
        }
        if hasValue {
            if let endDelimiter = endDelimiter {
                buffer.append(endDelimiter)
            }
        }
        return buffer
    }

}

