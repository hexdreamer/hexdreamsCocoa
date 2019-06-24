//
//  HTTP_1_1.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/14/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

public struct HTTP_1_1 {
    
    public enum Header : String {
        // General
        case cacheControl = "Cache-Control"
        case connection = "Connection"
        case date = "Date"
        case pragma = "Pragma"
        case trailer = "Trailer"
        case transferEncoding = "Transfer-Encoding"
        case upgrade = "Upgrade"
        case via = "Via"
        case warning = "Warning"
        // Request
        case accept = "Accept"
        case acceptCharset = "Accept-Charset"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case authorization = "Authorization"
        case expect = "Expect"
        case from = "From"
        case host = "Host"
        case ifMatch = "If-Match"
        case ifModifiedSince = "If-Modified-Since"
        case ifNoneMatch = "If-None-Match"
        case ifRange = "If-Range"
        case ifUnmodifiedSince = "If-Unmodified-Since"
        case maxForwards = "Max-Forwards"
        case proxyAuthorization = "Proxy-Authorization"
        case range = "Range"
        case referer = "Referer"
        case te = "TE"
        case userAgent = "User-Agent"
        // Response
        case acceptRanges = "Accept-Ranges"
        case age = "Age"
        case eTag = "ETag"
        case location = "Location"
        case proxyAuthenticate = "Proxy-Authenticate"
        case retryAfter = "Retry-After"
        case server = "Server"
        case vary = "Vary"
        case wwwAuthenticate = "WWW-Authenticate"
        // Entity
        case Allow = "Allow"
        case contentEncoding = "Content-Encoding"
        case contentLanguage = "Content-Language"
        case contentLength = "Content-Length"
        case contentLocation = "Content-Location"
        case contentMD5 = "Content-MD5"
        case contentRange = "Content-Range"
        case contentType = "Content-Type"
        case cxpires = "Expires"
        case lastModified = "Last-Modified"
    }
    
    public enum Method : String {
        case options = "OPTIONS"
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case trace = "TRACE"
        case connect = "CONNECT"
    }
    
    public enum Status : Int {
        // Informational
        case continueRequest = 100
        case switchingProtocols = 101
        case processing = 102
        
        // Success
        case ok = 200
        case created = 201
        case accepted = 202
        case nonAuthoritativeInformation = 203
        case oContent = 204
        case resetContent = 205
        case partialContent = 206
        case multiStatus = 207
        case alreadyReported = 208
        
        // Redirection
        case multipleChoices = 300
        case movedPermanently = 301
        case found = 302
        case seeOther = 303
        case notModified = 304
        case useProxy = 305
        case temporaryRedirect = 307
        case permanentRedirect = 308
        
        // Client Error
        case badRequest = 400
        case unauthorized = 401
        case paymentRequired = 402
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case notAcceptable = 406
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408
        case conflict = 409
        case gone = 410
        case lengthRequired = 411
        case preconditionFailed = 412
        case requestEntityTooLarge = 413
        case requestURITooLong = 414
        case unsupportedMediaType = 415
        case requestedRangeNotSatisfiable = 416
        case expectationFailed = 417
        case unprocessableEntity = 422
        case locked = 423
        case failedDependency = 424
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequests = 429
        case requestHeaderFieldsTooLarge = 431
        
        // Server Error
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case httpVersionNotSupported = 505
        case insufficientStorage = 507
        case loopDetected = 508
        case notExtended = 510
        case networkAuthenticationRequired = 511
    }
    
}
