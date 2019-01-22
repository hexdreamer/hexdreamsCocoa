//
//  HXWebRequest.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/14/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Network

fileprivate let MAX_HEADER_LENGTH = 16 * 1024

fileprivate let CRLF:Data = {
    guard let data = "\r\n".data(using:.ascii) else {
        fatalError("Couldn't initialize header delimiter")
    }
    return data
}()

fileprivate let COLON:Data = {
    guard let data = ":".data(using:.ascii) else {
        fatalError("Couldn't initialize header delimiter")
    }
    return data
}()

public class HXWebRequest : HXWebMessage {

    let readyHandler:(HXWebRequest)->Void
    
    var method:HTTP_1_1.Method?
    var uri:String?
    var httpVersion:String?
    
    private var runningData:Data = Data()
    private var headerBytesRead:Int = 0
    private var cursor:Data.Index = 0
    
    var contentLength:Int? {
        if let headerValue = self.headers[HTTP_1_1.Header.contentLength.rawValue],
            let length = Int(headerValue) {
            return length
        }
        return nil
    }
    
    init(networkConnection:NWConnection, queue:DispatchQueue, ready readyHandler:@escaping (HXWebRequest)->Void) {
        self.readyHandler = readyHandler
        super.init(networkConnection:networkConnection, queue:queue)
    }
    
    public override func start() {
        self.readRequestLine()
    }
    
    // https://tools.ietf.org/html/rfc2616#section-5.1
    // Request-Line   = Method SP Request-URI SP HTTP-Version CRLF
    func readRequestLine() {
        self.withNextLine { (data, range) in
            guard let line = String(data:data[range], encoding:.ascii) else {
                throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "Request line is not ASCII: \(data[range])"))
            }
            let components = line.split(separator:" ")
            if components.count != 3 {
                throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "Request line bad format: \(line))"))
            }
            let method = String(components[0])
            let uri = String(components[1])
            let httpVersion = String(components[2])
            self.method = HTTP_1_1.Method(rawValue:method)
            self.uri = uri
            self.httpVersion = httpVersion
            
            self.readHeader()
            return false
        }
    }
    
    func readHeader() {
        self.withNextLine { (data, range) in
            // An empty line signals the end of the header. We truncate the data so that only the body is left.
            if range.lowerBound == range.upperBound {
                self.runningData.removeSubrange(self.runningData.startIndex..<self.cursor)
                self.cursor = 0
                self.readyHandler(self)
                return false
            }
            
            let lineDesc = {
                String(data:data[range], encoding:.ascii) ?? "Error converting header line to a string: \(data[range])"
            }
            
            guard let colonRange = data.range(of:COLON, options:[], in:range) else {
                throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "Could not find colon delimiter in header: \(lineDesc())"))
            }
            guard let name = String(data:data[range.lowerBound..<colonRange.lowerBound], encoding:.ascii) else {
                throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "Could not read name in header: \(lineDesc())"))
            }
            guard let value = String(data:data[colonRange.upperBound..<range.upperBound], encoding:.ascii) else {
                throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "Could not read value in header: \(lineDesc())"))
            }
            //self.hxtrace([name:value])
            self.headers[name] = value.trimmingCharacters(in:.whitespaces)

            return true
        }
    }
    
    func withNextLine(_ processLine:@escaping (Data, Range<Data.Index>) throws -> Bool) {
        do {
            while let endOfLine = self.runningData.range(of:CRLF, options:[], in:self.cursor..<self.runningData.endIndex) {
                let lineRange = self.cursor..<endOfLine.lowerBound
                self.cursor = endOfLine.upperBound
                let loop = try processLine(self.runningData, lineRange)
                if !loop {
                    return
                }
            }
            
            if headerBytesRead > MAX_HEADER_LENGTH {
                throw hxthrown(HXWebServer.Errors.web(.badRequest, "Header length of \(MAX_HEADER_LENGTH) bytes exceeded."))
            }
        } catch {
            hxcaught(error)
            self.handleError(error)
        }
        
        self.networkConnection.receive(minimumIncompleteLength:0, maximumLength:MAX_HEADER_LENGTH + 1 - headerBytesRead) {
            (receivedData, context, isComplete, error) in
            do {
                guard let receivedData = receivedData else {
                    // Nothing has been read, so we'll assume it's timeout because nothing came in on the KeepAlive connection.
                    if self.headerBytesRead == 0 {
                        self.networkConnection.cancel()
                        return
                    }
                    throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "No data"))
                }
                if let error = error {
                    throw error
                }
                self.hxdebug(["data":receivedData.count])
                self.runningData.removeSubrange(self.runningData.startIndex..<self.cursor)
                self.runningData.append(receivedData)
                self.cursor = self.runningData.startIndex
                self.headerBytesRead += receivedData.count
                self.withNextLine(processLine)
            } catch {
                self.hxcaught(error)
                self.handleError(error)
            }
        }
    }
    
    public func withBody(_ processBody:@escaping (Data) throws -> Void) {
        do {
            guard let contentLength = self.contentLength else {
                self.handleError(hxthrown(HXWebServer.Errors.web(.badRequest, "no content length")))
                return
            }
            let expectedLength = contentLength - runningData.count
            if expectedLength == 0 {
                try processBody(self.runningData)
                return
            }
            
            self.networkConnection.receive(minimumIncompleteLength:expectedLength, maximumLength:expectedLength) { (receivedData, context, isComplete, error) in
                do {
                    guard let receivedData = receivedData else {
                        throw self.hxthrown(HXWebServer.Errors.web(.badRequest, "No data"))
                    }
                    if let error = error {
                        throw error
                    }
                    self.hxdebug(["data":receivedData.count])
                    self.runningData.append(receivedData)
                    try processBody(self.runningData)
                } catch {
                    self.handleError(error)
                }
            }
            
        } catch {
            hxcaught(error)
            self.handleError(error)
        }
    }
    
    func handleError(_ error:Error) {
        hxerror("Error", ["error":error])
        // generate error response and kill connection
    }
    
}
