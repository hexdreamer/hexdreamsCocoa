// hexdreamsCocoa
// ArrayExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension Array {
        
    func mapDict<Key> (
        _ getter:  (_ element: Element) throws -> Key?
    ) rethrows
    -> Dictionary<Key,Element>
    {
        var dict = Dictionary<Key,Element>(minimumCapacity: self.count)
        for obj in self {
            if let key = try getter(obj) {
                dict[key] = obj
            }
        }
        return dict
    }
}

public extension Array where Element == String {
    
    // Translate [String] to (const char * const *)
    // May want to replace this with Swift's own private function:
    // https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20160815/002957.html
    // https://github.com/apple/swift/blob/dfc3933a05264c0c19f7cd43ea0dca351f53ed48/stdlib/private/SwiftPrivate/SwiftPrivate.swift#L68

    func withArrayOfCStrings<R>(
        _ body: ([UnsafeMutablePointer<CChar>?]) -> R
    ) -> R {
        let argsCounts = self.map { $0.utf8.count + 1 }
        let argsOffsets = [ 0 ] + scan(argsCounts, 0, +)
        let argsBufferSize = argsOffsets.last!
        
        var argsBuffer: [UInt8] = []
        argsBuffer.reserveCapacity(argsBufferSize)
        for arg in self {
            argsBuffer.append(contentsOf: arg.utf8)
            argsBuffer.append(0)
        }
        
        return argsBuffer.withUnsafeMutableBufferPointer {
            (argsBuffer) in
            let ptr = UnsafeMutableRawPointer(argsBuffer.baseAddress!).bindMemory(
                to: CChar.self, capacity: argsBuffer.count)
            var cStrings: [UnsafeMutablePointer<CChar>?] = argsOffsets.map { ptr + $0 }
            cStrings[cStrings.count - 1] = nil
            return body(cStrings)
        }
    }
        
    /// Compute the prefix sum of `seq`.
    private func scan<S:Sequence,U>(
        _ seq: S,
        _ initial: U,
        _ combine: (U, S.Iterator.Element) -> U
    ) -> [U] {
        var result: [U] = []
        result.reserveCapacity(seq.underestimatedCount)
        var runningResult = initial
        for element in seq {
            runningResult = combine(runningResult, element)
            result.append(runningResult)
        }
        return result
    }

}
