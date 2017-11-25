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

    private let defaultInputBorderColor : UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    private let errorBordercolor: UIColor = UIColor(red: 198/255, green: 0, blue: 42/255, alpha: 1.0)
    
    @IBOutlet weak var senderName: UITextField!
    
    @IBOutlet weak var saveSenderNameButton: UIButton!
    @IBAction func saveSenderName(_ sender: Any) {
        guard let string = senderName.text else { return }
        
        if (string.isEmpty) {
            senderNameErrorLabel.text = "U dient een naam op te geven"
            senderName.layer.borderColor = errorBordercolor.cgColor
        } else {
            senderNameErrorLabel.text = ""
            senderName.layer.borderColor = defaultInputBorderColor.cgColor
            
            SwiftyPlistManager.shared.save(senderName.text!, forKey: "userName", toPlistWithName: "UserData") { (err) in
                if err == nil {
                    self.showToast(message: "Uw naam is opgeslagen!", errorCode: 200, warning: false, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
                } else {
                    self.showToast(message: "Er is iets mis gegaan, probeer het nogmaals", errorCode: 500, warning: true, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
                }
            }
        }
    }
    
    @IBOutlet weak var senderNameErrorLabel: UILabel!
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
        guard let string = message.text else { return }
        
        if (string.isEmpty) {
            messageErrorLabel.text = "U dient een bericht op te geven"
            message.layer.borderColor = errorBordercolor.cgColor
        } else {
            messageErrorLabel.text = ""
            message.layer.borderColor = defaultInputBorderColor.cgColor
        }
    }
    
    @IBOutlet weak var messageErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendMessageButton.layer.cornerRadius = 5
        
        SwiftyPlistManager.shared.getValue(for: "userName", fromPlistWithName: "UserData") { (result, err) in
            if err == nil {
                senderName.text = result as? String
            }
        }
        
        message.layer.borderWidth = 1.0
        message.layer.borderColor = defaultInputBorderColor.cgColor
        message.layer.cornerRadius = 5.0
        
        senderName.layer.borderWidth = 1.0
        senderName.layer.borderColor = defaultInputBorderColor.cgColor
        senderName.layer.cornerRadius = 5.0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
