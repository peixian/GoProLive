//
//  ViewController.swift
//  GoProLive
//
//  Created by DeLosSantos, Louis on 5/25/17.
//  Copyright © 2017 DeLosSantos, Louis. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController, UITextFieldDelegate {
    var gp: GoPro? = nil
    var proxy: Proxy? = nil
    let httpClient: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "localhost": .disableEvaluation,
            "10.5.5.9": .disableEvaluation,
            "35.185.59.154": .disableEvaluation,
            ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    var streamingIP = ""
    var streamingPort = ""
    
    //MARK: Outlets
    @IBOutlet weak var pairingCodeInputField: UITextField!
    @IBOutlet weak var isConnectedField: UITextField!
    @IBOutlet weak var ingestServerIP: UITextField!
    @IBOutlet weak var ingestServerPort: UITextField!
    @IBOutlet weak var urlField: UITextField!
    
    //MARK: Actions
    @IBAction func pairingCodeInputButton(_ sender: UIButton) {
        self.gp = GoPro()
        
        // Check that value is in input field
        let pairingCode = Int(pairingCodeInputField.text!)
        if pairingCode != nil {
            self.gp?.pairingCode = pairingCode!
            //TODO: Add try catch
            self.gp?.startPair()
        }
        
        pairingCodeInputField.resignFirstResponder()
    }
    
    @IBAction func startStreamingButton(_ sender: UIButton) {
        self.ingestServerIP.resignFirstResponder()
        self.ingestServerPort.resignFirstResponder()
        
        self.gp = GoPro()
        self.gp?.isConnected = true
        
        if !self.gp!.isConnected{
            print("Is not paired, attempt pairing again")
            return
        }
        
        httpClient.request("http://35.185.59.154:8080/new")
            .responseJSON { response in
                self.streamingPort = String(data: response.data!, encoding: .utf8)!
                self.urlField.text = "http://35.185.59.154:8080/\(self.streamingPort)/hls"
                print("Streaming Port")
                print(self.streamingPort)
                self.gp?.startStream() { streamStatus in
                    if streamStatus {
                        // Start proxying
                        self.proxy = Proxy(gp: self.gp!)
//                        self.proxy?.ingestServerAddr = self.ingestServerIP.text!
                        self.proxy?.ingestServerAddr = "35.185.59.154"
                        self.proxy?.ingestServerPort = UInt16(self.streamingPort)!
                        self.proxy?.startProxying()
                    }
                }
                
        }

    }
    @IBAction func stopStreamingButton(_ sender: Any) {
        if self.proxy == nil {
            print("Tried to stop streaming with no active stream")
            return
        }
        self.urlField.text = "Stream ended."
        self.proxy!.stopProxying()
    }
    
    //MARK: UIViewController implementations
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

