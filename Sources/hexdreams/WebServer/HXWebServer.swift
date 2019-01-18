//
//  HXWebServer.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/9/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Network

public class HXWebServer {
    
    let name:String
    let queue:DispatchQueue
    var listener:NWListener?
    var requests = [HXWebRequest]()
    
    var requestHandlers = [String:HXWebRequestHandler.Type]()
    
    public init(name:String) {
        self.name = name
        self.queue = DispatchQueue(label:"HXWebServer:\(name)", qos:.default, attributes:[.concurrent], autoreleaseFrequency:.workItem, target:nil)
    }
    
    public func start() throws {
        let listener = try NWListener(using:.tcp)
        // Advertise a Bonjour service
        listener.service = NWListener.Service(name:name, type:"_hxlogging._tcp.", domain:"", txtRecord:nil)
        listener.newConnectionHandler = { (connection) in
            connection.start(queue:self.queue)
            self.initiateRequest(on:connection)
        }
        self.listener = listener
        listener.start(queue:queue)
    }
    
    func stop() {
        if let listener = self.listener {
            listener.cancel()
            self.listener = nil
        }
    }
    
    private func initiateRequest(on connection:NWConnection) {
        let request = HXWebRequest(networkConnection:connection, queue:self.queue, ready:{
            self.handleRequest($0, on:connection)
        })
        self.requests.append(request)
        request.start()
    }
    
    private func handleRequest(_ request:HXWebRequest, on connection:NWConnection) {
        guard let handlerClass = self.requestHandlerFor(request) else {
            hxerror("no handler registered for \(request.uri ?? "nil"))")
            return
        }
        let response = HXWebResponse(networkConnection:connection, queue:queue, completion:{ (_) in
            self.retireRequest(request, on:connection)
        })
        let handler = handlerClass.init(request:request, response:response)
        handler.start()
    }
    
    private func retireRequest(_ request:HXWebRequest, on connection:NWConnection) {
        self.requests.removeAll(where:{$0 === request})
        // KeepAlive connection, so we just start another request again
        self.initiateRequest(on:connection)
    }
    
    private func requestHandlerFor(_ request:HXWebRequest) -> HXWebRequestHandler.Type? {
        guard let requestURI = request.uri else {
            return nil
        }
        for (key,value) in self.requestHandlers {
            if requestURI.hasPrefix(key) {
                return value
            }
        }
        return nil
    }
    
    public func registerRequestHandler(urlPrefix:String, handlerClass:HXWebRequestHandler.Type) {
        self.requestHandlers[urlPrefix] = handlerClass
    }
    
}
