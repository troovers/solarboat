//
//  MessageViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class MessageViewController: UIViewController {

    @IBOutlet weak var senderName: UITextField!
    
    @IBOutlet weak var saveSenderNameButton: UIButton!
    @IBAction func saveSenderName(_ sender: Any) {
        SwiftyPlistManager.shared.save(senderName.text!, forKey: "userName", toPlistWithName: "UserData") { (err) in
            if err == nil {
                self.showToast(message: "Uw naam is opgeslagen!", errorCode: 200, warning: false, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
            } else {
                self.showToast(message: "Er is iets mis gegaan, probeer het nogmaals", errorCode: 500, warning: true, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
            }
        }
    }
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendMessageButton.layer.cornerRadius = 5
        
        SwiftyPlistManager.shared.getValue(for: "userName", fromPlistWithName: "UserData") { (result, err) in
            if err == nil {
                senderName.text = result as? String
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
