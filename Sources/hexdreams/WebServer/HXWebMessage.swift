//
//  HXWebMessage.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/14/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

import Network

public class HXWebMessage : HXObject {
    
    let networkConnection:NWConnection
    let queue:DispatchQueue

    var headers = [String:String]()
    
    init(networkConnection:NWConnection, queue:DispatchQueue) {
        self.networkConnection = networkConnection
        self.queue = queue
    }

    public func start() {
        fatalError("start() not implemented in \(self)")
    }
    
}
