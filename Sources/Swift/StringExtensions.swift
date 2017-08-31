// hexdreamsCocoa
// StringExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension String {
    
    public func split(pattern :String) -> [String] {
        var results = [String]()
        var remainingRange = self.startIndex..<self.endIndex;
        while let matchRange = self.range(of:pattern, options: .regularExpression, range: remainingRange, locale: nil) {
            results.append(String(self[remainingRange.lowerBound..<matchRange.lowerBound]))
            remainingRange = matchRange.upperBound..<self.endIndex
        }
        results.append(String(self[remainingRange]))
        return results
    }
    
    /**
     #strippedOf(prefix:)
     If the prefix exists on the string, then it is stripped, and the remainder is returned. If the prefix does not exist, returns nil
     */
    public func strippedOf(prefix :String) -> String? {
        if let prefixRange = self.range(of:prefix) {
            if prefixRange.lowerBound == self.startIndex {
                return String(self[prefixRange.upperBound...])
            }
        }
        return nil
    }
    
    /**
     #strippedOf(suffix:)
     If the suffix exists on the string, then it is stripped, and the remainder is returned. If the suffix does not exist, returns nil
     */
    public func strippedOf(suffix :String) -> String? {
        if let suffixRange = self.range(of:suffix) {
            if suffixRange.upperBound == self.endIndex {
                return String(self[...suffixRange.lowerBound])
            }
        }
        return nil
    }
    
    public func stripedOfQuotes() -> String {
        var x :String?
            
        x = self.strippedOf(prefix:"\"")
        if x == nil {
            x = self
        }
        x = self.strippedOf(suffix:"\"")
        
        guard let nnx = x else {
            return self
        }
        return nnx
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
