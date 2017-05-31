//
//  Proxy.swift
//  GoProLive
//
//  Created by DeLosSantos, Louis on 5/30/17.
//  Copyright © 2017 DeLosSantos, Louis. All rights reserved.
//

import Foundation
import CocoaAsyncSocket


class Proxy: NSObject, GCDAsyncUdpSocketDelegate {
    var goPro: GoPro? = nil
    var ingestServerAddr = ""
    var ingestServerPort: UInt16 = 0
    var outSocket: GCDAsyncUdpSocket? = nil
    var keepAliveSocket: GCDAsyncUdpSocket? = nil
    var timerQueue: DispatchQueue? = nil
    var timer: DispatchSourceTimer? = nil
    
        
    
    init(gp goPro: GoPro) {
        self.goPro = goPro
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        var host: NSString?
        var port: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
        print(data)
        
        // Forward data to ingest server
        self.outSocket!.send(data, toHost: self.ingestServerAddr, port: self.ingestServerPort, withTimeout: 1000, tag: 0)
        
    }
    
    func startProxying() {
        
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try socket.bind(toPort: UInt16(self.goPro!.streamingPort))
            try socket.beginReceiving()
            self.keepAliveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            self.outSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
        } catch {
            print(error)
        }
        
        // Schedule keepAlive task
        timerQueue = DispatchQueue(label: "keepAliveQueue")
        timer = DispatchSource.makeTimerSource(queue: self.timerQueue!)
        
        timer!.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(2))
        
        timer!.setEventHandler() { [weak self] in
            print("Sending a keep alive!!")
            
            // Construct byte array
            let msg: [UInt8] = Array("_GPHD_:0:0:2:0.000000".utf8)
            print(msg)
            
            
            let d = Data(msg)
            
            self?.keepAliveSocket!.send(d, toHost: (self?.goPro?.goProIP)!, port: UInt16((self?.goPro?.streamingPort)!), withTimeout: 1000, tag: 0)
            
        }
        
        timer!.activate()
    
        
    }
    
}
