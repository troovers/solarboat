//
//  MessageViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class MessageViewController: UIViewController, UITableViewDataSource {

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
            
            UserDefaults.standard.set(senderName.text!, forKey: "userName")
            
            self.showToast(message: "Uw naam is opgeslagen!", errorCode: 200, warning: false, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
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
    
    private var messages = [Message]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        sendMessageButton.layer.cornerRadius = 5
        
        senderName.text = UserDefaults.standard.string(forKey: "userName")
        
        message.layer.borderWidth = 1.0
        message.layer.borderColor = defaultInputBorderColor.cgColor
        message.layer.cornerRadius = 5.0
        
        senderName.layer.borderWidth = 1.0
        senderName.layer.borderColor = defaultInputBorderColor.cgColor
        senderName.layer.cornerRadius = 5.0
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        messages.append(Message(date: "25-11 10:33", from: "Thomas Roovers", message: "Ik heb dit bericht verstuurd"))
        messages.append(Message(date: "25-11 10:36", from: "Thomas Roovers", message: "Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd"))
        messages.append(Message(date: "25-11 10:39", from: "Thomas Roovers", message: "Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd"))
        messages.append(Message(date: "25-11 10:43", from: "Thomas Roovers", message: "Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd, Ik heb dit bericht verstuurd"))
        
        tableView.reloadData()
    }
    
    
    // Set the number of sections in the tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     Set the number of rows in the tableview
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    /**
     Generate the cell for the index
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as! MessageTableViewCell
            
        let message = messages[indexPath.row] as Message
        
        cell.date.text = message.date
        cell.message.text = message.message
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
