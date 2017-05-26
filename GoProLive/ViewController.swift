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
    
    //MARK: Actions
    @IBAction func requestCall(_ sender: UIButton) {
        Alamofire.request("http://www.google.com").response { response in
            let sCode = "\(response.response!.statusCode)"
            self.responseDisplay.text = sCode
            return
        }
        
    }

    //MARK: Outlets
    @IBOutlet weak var responseDisplay: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

