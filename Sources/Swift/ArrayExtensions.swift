// hexdreamsCocoa
// ArrayExtensions.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public extension Array {

    public func mapDict<Key>(
        _ getter: (element: Element) -> Key?
        ) throws -> Dictionary<Key,Element>
    {
        var dict = Dictionary<Key,Element>(minimumCapacity: self.count)
        for obj in self {
            guard let key = getter(element: obj) else {
                throw hexdreamsCocoa.Error.ObjectNotFound(self, "mapDict", "Array.mapDict: object does not contain value for key: \(obj)")
            }
            dict[key] = obj
        }
        return dict
    }

    // Translate [String] to (const char * const *), which translates to Swift as
    public func cStringArray() throws -> ArrayBridge<Element,CChar> {
        return try ArrayBridge<Element,CChar>(array:self) {
            guard let item = $0 as? String,
                  let translated = item.cString(using: .utf8) else {
                throw hexdreamsCocoa.Error.InvalidArgumentError
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

    init(array :[SwiftType], transform: @noescape (SwiftType) throws -> [CType]) throws {
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

