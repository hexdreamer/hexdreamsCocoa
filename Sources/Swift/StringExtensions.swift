// hexdreamsCocoa
// StringExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension String {
    
    public func split(_ pattern :String) -> [String] {
        var results = [String]()
        var remaining = self.startIndex..<self.endIndex;
        while let matchRange = self.range(of:pattern, options: .regularExpression, range: remaining, locale: nil) {
            results.append(self.substring(with: remaining.lowerBound..<matchRange.lowerBound))
            remaining = matchRange.upperBound..<self.endIndex
        }
        results.append(self.substring(with:remaining))
        return results
    }
    
}
