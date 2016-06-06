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
                throw hexdreams.Error.ObjectNotFound(self, "mapDict", "Array.mapDict: object does not contain value for key: \(obj)")
            }
            dict[key] = obj
        }
        return dict
    }
}