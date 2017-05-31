//
//  Proxy.swift
//  GoProLive
//
//  Created by DeLosSantos, Louis on 5/30/17.
//  Copyright © 2017 DeLosSantos, Louis. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

let packetEnqueueKey = "packetEnqueue"


class Proxy: NSObject, GCDAsyncUdpSocketDelegate {
    var goPro: GoPro? = nil
    var ingestServerAddr = ""
    var ingestServerPort: UInt16 = 0
    var outSocket: GCDAsyncUdpSocket? = nil
    var keepAliveSocket: GCDAsyncUdpSocket? = nil
    var timerQueue: DispatchQueue? = nil
    var timer: DispatchSourceTimer? = nil
    var packetQueue: Queue<Data>? = nil

    
    init(gp goPro: GoPro) {
        self.goPro = goPro
        self.packetQueue = Queue<Data>()
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        print(data)
        
        // Write data to Queue
        self.packetQueue?.enqueue(value: data)
        
        //send a notification
        NotificationCenter.default.post(name: Notification.Name(rawValue: packetEnqueueKey), object: self)
    }
    
    func dequeue() {
        // Read off Queue
        var packet = self.packetQueue?.dequeue()
        
        while packet != nil {
            print("Dequeued Packet: \(packet)")
            
            self.outSocket!.send(packet!, toHost: self.ingestServerAddr, port: self.ingestServerPort, withTimeout: 1000, tag: 0)
            
            packet = self.packetQueue?.dequeue()
        
       
        }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(Proxy.dequeue), name: NSNotification.Name(rawValue: packetEnqueueKey), object: nil)
    }
    
}
