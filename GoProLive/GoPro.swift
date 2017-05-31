//
//  GoPro.swift
//  GoProLive
//
//  Created by DeLosSantos, Louis on 5/30/17.
//  Copyright © 2017 DeLosSantos, Louis. All rights reserved.
//

import Foundation
import Alamofire


class GoPro {
    var pairingCode: Int = 0
    let goProIP: String = "10.5.5.9"
    let streamingPort: Int16 = 8554
    var isConnected = false
    var isStreaming = false
    let httpClient: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "localhost": .disableEvaluation,
        "10.5.5.9": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    func pair(completionHandler: @escaping (Int) -> ()){
        // Use pairingCode to start pairing 
        let requestString = "https://\(self.goProIP)/gpPair?c=start&pin=\(self.pairingCode)&mode=0"
        self.httpClient.request(requestString).validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case.success:
                    // Finish pairing
                    let requestString = "https://\(self.goProIP)/gpPair?c=finish&pin=\(self.pairingCode)&mode=0"
                    self.httpClient.request(requestString).validate(statusCode: 200..<300)
                        .responseData { response in
                            switch response.result {
                            case.success:
                                print("Successfully paired")
                                completionHandler(1)
                            case.failure(let error):
                                print("Could not finish pairing, \(error)")
                                completionHandler(0)
                            }
                    }
        
                case.failure(let error):
                    print("Could not finish pairing #2 \(error)")
    
                    completionHandler(0 as Int)
                }
        }
    }
    
    func startPair() -> Void {
        self.pair() { connectionStatus in
            if connectionStatus == 1 {
                self.isConnected = true
            }
        }
    }
    
    func startStream(callbackHandler: @escaping (Bool) -> ()) {
        let requestString = "http://\(self.goProIP)/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart"
        self.httpClient.request(requestString).validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case.success:
                    print("Started streaming!")
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                    }
                    callbackHandler(true)
                case.failure(let error):
                    print("Could not start streaming: \(error)")
                    callbackHandler(false)
                }
        }
    }
}
