// hexdreamsCocoa
// StringExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension String {
    
    public func split(pattern :String) -> [Substring] {
        var results = [Substring]()
        var remainingRange = self.startIndex..<self.endIndex;
        while let matchRange = self.range(of:pattern, options: .regularExpression, range: remainingRange) {
            results.append(self[remainingRange.lowerBound..<matchRange.lowerBound])
            remainingRange = matchRange.upperBound..<self.endIndex
        }
        results.append(self[remainingRange])
        return results
    }
    
    /**
     #strippedOf(prefix:)
     If the prefix exists on the string, then it is stripped, and the remainder is returned. If the prefix does not exist, returns nil
     */
    public func strippedOf(prefix :String) -> Substring? {
        if let prefixRange = self.range(of:prefix) {
            if prefixRange.lowerBound == self.startIndex {
                return self[prefixRange.upperBound...]
            }
        }
        return nil
    }
    
    /**
     #strippedOf(suffix:)
     If the suffix exists on the string, then it is stripped, and the remainder is returned. If the suffix does not exist, returns nil
     */
    public func strippedOf(suffix :String) -> Substring? {
        if let suffixRange = self.range(of:suffix) {
            if suffixRange.upperBound == self.endIndex {
                return self[...suffixRange.lowerBound]
            }
        }
        return nil
    }
    
    public func strippedOf(fixes :String) -> Substring? {
        if let prefixRange = self.range(of:fixes) {
            if prefixRange.lowerBound == self.startIndex {
                let remainingRange = prefixRange.upperBound..<self.endIndex;
                if let suffixRange = self.range(of:fixes, range:remainingRange) {
                    return self[prefixRange.upperBound...suffixRange.lowerBound]
                }
            }
        }
        return nil
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
