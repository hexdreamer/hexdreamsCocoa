// hexdreamsCocoa
// StringExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension String {
    
    public func split(pattern :String) -> [String] {
        var results = [String]()
        var remaining = self.startIndex..<self.endIndex;
        while let matchRange = self.rangeOfString(pattern, options: .RegularExpressionSearch, range: remaining, locale: nil) {
            results.append(self.substringWithRange(remaining.startIndex..<matchRange.startIndex))
            remaining.startIndex = matchRange.endIndex
        }
        results.append(self.substringWithRange(remaining))
        return results
    }
    
}
