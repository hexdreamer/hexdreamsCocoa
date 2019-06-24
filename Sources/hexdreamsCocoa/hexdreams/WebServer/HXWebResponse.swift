//
//  HXWebResponse.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/14/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Foundation
import Network

fileprivate let CRLF:Data = {
    guard let data = "\r\n".data(using:.ascii) else {
        fatalError("Couldn't initialize header delimiter")
    }
    return data
}()

public class HXWebResponse : HXWebMessage {
    
    public var status:HTTP_1_1.Status?
    public var statusMessage:String?
    var completionHandler:(HXWebResponse)->Void
    
    init(networkConnection:NWConnection, queue:DispatchQueue, completion:@escaping (HXWebResponse)->Void) {
        self.completionHandler = completion
        super.init(networkConnection:networkConnection, queue:queue)
        self.headers[HTTP_1_1.Header.contentLength.rawValue] = "0"
    }

    public override func start() {
        var responseData = Data()

        do {
            let status:HTTP_1_1.Status
            let statusMessage:String
            switch self.status {
            case .none:
                status = HTTP_1_1.Status.internalServerError
                statusMessage = "Status not set"
            case .some(let someStatus):
                status = someStatus
                switch self.statusMessage {
                case.none:
                    if status == .ok {
                        statusMessage = "OK"
                    } else {
                        statusMessage = ""
                    }
                case.some(let someMessage):
                    statusMessage = someMessage
                }
            }
            let escapedMessage = try self.escape(statusMessage)
            let statusLine = "HTTP/1.1 \(status.rawValue) \(escapedMessage)"
            responseData.append(try self.toData(statusLine))
            responseData.append(CRLF)
            
            for (key,value) in self.headers {
                let headerline = "\(key): \(try self.escape(value))"
                responseData.append(try self.toData(headerline))
                responseData.append(CRLF)
            }
            responseData.append(CRLF)
        } catch {
            hxcaught(error)
            do {
                responseData.removeAll()
                let statusLine = "HTTP/1.1 \(HTTP_1_1.Status.internalServerError) Error generating response"
                responseData.append(try self.toData(statusLine))
                responseData.append(CRLF)
                let contentLengthLine = "\(HTTP_1_1.Header.contentLength.rawValue): 0"
                responseData.append(try self.toData(contentLengthLine))
                responseData.append(CRLF)
                responseData.append(CRLF)
            } catch {
                hxerror("Error generating error response", ["error":error])
                self.networkConnection.cancel()
                return
            }
        }

        self.networkConnection.send(content:responseData, isComplete:true, completion:.contentProcessed({ (error) in
            self.completionHandler(self)
        }))
    }

    func toData(_ str:String) throws -> Data {
        guard let data = str.data(using:.ascii) else {
            throw hxthrown(.invalidArgument("could not convert to data"))
        }
        return data
    }
    
    func escape(_ str:String) throws -> String {
        guard let escaped = str.addingPercentEncoding(withAllowedCharacters:.urlPathAllowed) else {
            throw hxthrown(.invalidArgument("could not escape string"))
        }
        return escaped
    }
}
