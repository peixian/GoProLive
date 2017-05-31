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
    
    //MARK: Outlets
    @IBOutlet weak var pairingCodeInputField: UITextField!
    @IBOutlet weak var isConnectedField: UITextField!
    
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
    }
    
    @IBAction func startStreamingButton(_ sender: UIButton) {
        self.gp = GoPro()
        self.gp?.isConnected = true
        
        if !self.gp!.isConnected{
            print("Is not paired, attempt pairing again")
            return
        }
        self.gp?.startStream() { streamStatus in
            if streamStatus {
                // Start proxying
                self.proxy = Proxy(gp: self.gp!)
                self.proxy?.ingestServerAddr = "127.0.0.1"
                self.proxy?.ingestServerPort = 5566
                self.proxy?.startProxying()
            }
            
        }
    }
    
    //MARK: UIViewController implementations
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

