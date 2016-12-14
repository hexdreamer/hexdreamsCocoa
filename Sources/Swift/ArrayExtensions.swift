// hexdreamsCocoa
// ArrayExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension Array {

    public func mapDict<Key>(
        _ getter: (_ element: Element) -> Key?
        ) throws -> Dictionary<Key,Element>
    {
        var dict = Dictionary<Key,Element>(minimumCapacity: self.count)
        for obj in self {
            guard let key = getter(obj) else {
                throw Errors.ObjectNotFound(self, "mapDict", "Array.mapDict: object does not contain value for key: \(obj)")
            }
            dict[key] = obj
        }
        return dict
    }

    // Translate [String] to (const char * const *), which translates to Swift as
    // May want to replace this with Swift's own private function:
    // https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20160815/002957.html
    // https://github.com/apple/swift/blob/dfc3933a05264c0c19f7cd43ea0dca351f53ed48/stdlib/private/SwiftPrivate/SwiftPrivate.swift#L68
    public func cStringArray() throws -> ArrayBridge<Element,CChar> {
        return try ArrayBridge<Element,CChar>(array:self) {
            guard let item = $0 as? String,
                  let translated = item.cString(using: .utf8) else {
                throw Errors.InvalidArgumentError("blah")
            }
            return translated
        }
    }

    /*
     The more generic form, which we'll save for later.
    public func cArray<CType>() throws -> ArrayBridge<Element,CType> {
        return ArrayBridge<Element,CType>(array:self)
    }
    */
}

/*
 We need to have this intermediate object around to hold on to the translated objects, otherwise they will go away.
 The UnsafePointer won't hold on to the objects that it's pointing to.
 */
public struct ArrayBridge<SwiftType,CType> {

    let originals  :[SwiftType]
    let translated :[[CType]]
    let pointers   :[UnsafePointer<CType>?]
    public let pointer    :UnsafePointer<UnsafePointer<CType>?>

    init(array :[SwiftType], transform: (SwiftType) throws -> [CType]) throws {
        self.originals = array
        self.translated = try array.map(transform)

        var pointers = [UnsafePointer<CType>?]()
        for item in translated {
            pointers.append(UnsafePointer<CType>(item))
        }
        pointers.append(nil)
        self.pointers = pointers
        self.pointer = UnsafePointer(self.pointers)
    }
}

