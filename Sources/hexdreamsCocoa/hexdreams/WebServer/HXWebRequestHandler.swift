//
//  HXWebRequestHandler.swift
//  DreamSight
//
//  Created by Kenny Leung on 1/14/19.
//  Copyright © 2019 hexdreams. All rights reserved.
//

open class HXWebRequestHandler : HXObject {
    
    public let request:HXWebRequest
    public let response:HXWebResponse
    
    public required init(request:HXWebRequest, response:HXWebResponse) {
        self.request = request
        self.response = response
    }
    
    open func start() {
        fatalError("start not implemented in \(self)")
    }
    
}
