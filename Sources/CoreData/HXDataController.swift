// hexdreamsCocoa
// HXDataController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

// http://stackoverflow.com/questions/24393837/swift-fetch-method-with-generics

import Foundation
import CoreData
import UIKit

open class HXDataController {

    public enum Errors : Error {
        case BadJSON(message :String)
        case EntityNotFound(message :String)
        case MissingPrimaryKey(dictionary: [String:AnyObject])
        case General(message :String)
    }

    public lazy var modelController :HXModelController = {
        return HXModelController(modelURL: self.modelURL(), storeURL:self.storeURL())
        } ()

    public lazy var queue :OperationQueue = {
        return OperationQueue()
        }()

    public lazy var urlSession :URLSession = {
        return URLSession(configuration: URLSessionConfiguration.ephemeral, delegate:nil, delegateQueue:self.queue)
        }()

    public var moc :NSManagedObjectContext {
        return self.modelController.moc
    }

    public var writemoc :NSManagedObjectContext {
        return self.modelController.writemoc
    }

    open func modelURL() -> URL {
        fatalError("Needs to be overridden")
    }

    public func storeURL() -> URL {
        guard let filename = self.modelURL().lastPathComponent as NSString? else {
            fatalError("Failed to generate storeURL")
        }
        let modelName = filename.deletingPathExtension
        return UIApplication.applicationDocumentsDirectory().appendingPathComponent("\(modelName).sqlite")
    }

    public init() {
    }

    public struct UpdateEntityOptions : OptionSet {
        public let rawValue : Int
        static let DeleteExtras = UpdateEntityOptions(rawValue: 1)
        static let UseStreaming = UpdateEntityOptions(rawValue: 2)
        static let ErrorTolerant = UpdateEntityOptions(rawValue:4)

        public init(rawValue :Int) {
            self.rawValue = rawValue
        }
    }

}


