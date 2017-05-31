//
//  Proxy.swift
//  GoProLive
//
//  Created by DeLosSantos, Louis on 5/30/17.
//  Copyright © 2017 DeLosSantos, Louis. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
//import Socket

class Proxy: NSObject, GCDAsyncUdpSocketDelegate {
    var goPro: GoPro? = nil
    var ingestServer = ""
    
    init(gp goPro: GoPro) {
        self.goPro = goPro
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        var host: NSString?
        var port: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
        
        print(data)
    }
    
    func startProxying() {
//        // Create UDP Socket
//        var socket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)
//        
//        // Set socket buffer
//        socket.readBufferSize = 2097152
        
        let port: UInt16 = 8554   // Port
    
        
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try socket.bind(toPort: port)
            try socket.beginReceiving()
        } catch {
            print(error)
        }
        
    }
    
}
