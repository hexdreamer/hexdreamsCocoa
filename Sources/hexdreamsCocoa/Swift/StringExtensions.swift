// hexdreamsCocoa
// StringExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

public extension StringProtocol {

    var hxlastPathComponent:Self.SubSequence {
        if let lastSlash = self.lastIndex(of:"/") {
            return self[self.index(after:lastSlash)..<self.endIndex]
        } else {
            return self[self.startIndex..<self.endIndex]
        }
    }

    func hxisBlank() -> Bool {
        if self.isEmpty {
            return true
        }

        let charset = CharacterSet.whitespacesAndNewlines
        for char in self.unicodeScalars {
            if !charset.contains(char) {
                return false
            }
        }
        return true
    }

    func hxsplit<T:StringProtocol>(pattern:T) -> [Self.SubSequence]  {
        var results = [Self.SubSequence]()
        var remainingRange = self.startIndex..<self.endIndex
        while let matchRange = self.range(of:pattern, options:.regularExpression, range:remainingRange) {
            results.append(self[remainingRange.lowerBound..<matchRange.lowerBound])
            remainingRange = matchRange.upperBound..<self.endIndex
        }
        results.append(self[remainingRange])
        return results
    }
    
    func hxhead(_ count:Int) -> Self.SubSequence {
        var headRange = self.startIndex..<self.endIndex
        var remainingRange = self.startIndex..<self.endIndex
        var lines = 0
        while let matchRange = self.range(of:"\n", options:.literal, range:remainingRange) {
            headRange = self.startIndex..<matchRange.upperBound
            remainingRange = matchRange.upperBound..<self.endIndex
            lines += 1
            if lines >= count {
                break
            }
        }
        if lines < count {
            headRange = self.startIndex..<self.endIndex
        }
        return self[headRange]
    }
    
    /**
     #strippedOf(prefix:)
     If the prefix exists on the string, then it is stripped, and the remainder is returned. If the prefix does not exist, returns nil
     */
    func hxexcluding<T:StringProtocol>(prefix:T) -> Self.SubSequence {
        if let prefixRange = self.range(of:prefix) {
            if prefixRange.lowerBound == self.startIndex {
                return self[prefixRange.upperBound...]
            }
        }
        return self[self.startIndex..<self.endIndex]
    }
    
    /**
     #strippedOf(suffix:)
     If the suffix exists on the string, then it is stripped, and the remainder is returned. If the suffix does not exist, returns nil
     */
    func hxexcluding<T:StringProtocol>(suffix:T) -> Self.SubSequence {
        if let suffixRange = self.range(of:suffix) {
            if suffixRange.upperBound == self.endIndex {
                return self[..<suffixRange.lowerBound]
            }
        }
        return self[self.startIndex..<self.endIndex]
    }
    
    func hxexcluding<T:StringProtocol>(fixes:T) -> Self.SubSequence {
        if let prefixRange = self.range(of:fixes) {
            if prefixRange.lowerBound == self.startIndex {
                let remainingRange = prefixRange.upperBound..<self.endIndex;
                if let suffixRange = self.range(of:fixes, range:remainingRange) {
                    return self[prefixRange.upperBound...suffixRange.lowerBound]
                }
            }
        }
        return self[self.startIndex..<self.endIndex]
    }
    
    // https://stackoverflow.com/questions/32338137/padding-a-swift-string-for-printing
    func hxpad(width:Int, with:Character=" ", truncate:Bool=false) -> String {
        let count = self.count
        if width == count {
            return String(self)
        }
        guard width > count else {
            return truncate ? String(suffix(width)) : String(self)
        }
        return String(repeating:with, count: width - count) + self
    }
    
    func hxpadRight(width:Int, with:Character=" ", truncate:Bool=false) -> String {
        let count = self.count
        if width == count {
            return String(self)
        }
        guard width > count else {
            return truncate ? String(prefix(width)) : String(self)
        }
        return self + String(repeating:with, count: width - count)
    }
        
}

// MARK: Operator Support
public func ≅ (left: String, right: String) -> Bool {
    if       left.caseInsensitiveCompare(right) == .orderedSame
    || left.caseInsensitiveCompare(right + "s") == .orderedSame
    || right.caseInsensitiveCompare(left + "s") == .orderedSame {
        return true
    }
    return false
}

infix operator ≅ : ComparisonPrecedence
