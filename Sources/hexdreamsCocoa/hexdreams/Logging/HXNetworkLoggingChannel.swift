// hexdreamsCocoa
// HXNetworkLoggingChannel.swift
// Copyright © 2019 Kenny Leung
// This code is PUBLIC DOMAIN

import Foundation

class HXNetworkLoggingChannel : HXLoggingChannel {
    
    private let serialize = DispatchQueue(label:"HXNetworkLoggingChannel", qos:.background, attributes:[], autoreleaseFrequency:.workItem, target:nil)

    let hostname:String
    let port:Int
    
    var logs = [HXLog]()
    var flushEnqueued = false
    var task:URLSessionDataTask?

    init(hostname:String, port:Int) {
        self.hostname = hostname
        self.port = port
    }
    
    // MARK: - HXLoggingChannel
    public func log(_ log:HXLog) {
        self.serialize.async {
            self.logs.append(log)
            if !self.flushEnqueued {
                self.serialize.async {
                    self.flushLogs()
                }
                self.flushEnqueued = true
            }
        }
    }
    
    func addLogs(_ logs:[HXLog]) {
        self.serialize.async {
            self.logs.append(contentsOf:logs)
        }
    }

    func flushLogs() {
        // print("## Flushing \(self.logs.count) logs")
        defer {
            self.logs.removeAll()
        }
        
        guard let url = URL(string:"http://\(self.hostname):\(self.port)/HXLog") else {
            return
        }
        
        do {
            var request = URLRequest(url:url)
            request.httpMethod = "PUT"
            //print("\(self.logs.map{$0.propertyList})")
            request.httpBody = try JSONSerialization.data(withJSONObject:self.logs.map{$0.propertyList}, options:[.sortedKeys, .prettyPrinted])
            self.task = URLSession.shared.dataTask(with:request) { (data, response, error) in
                // print("completed: \(String(describing: error))")
                self.serialize.async {
                    self.flushEnqueued = false
                    if self.logs.count > 0 {
                        self.serialize.async {
                            self.flushLogs()
                        }
                        self.flushEnqueued = true
                    }
                }
            }
            task?.resume()
        } catch {
            print("Error trying to send log: \(error)")
        }
        
    }

}
