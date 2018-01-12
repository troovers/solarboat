//
//  MessageViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import SwiftyPlistManager
import Alamofire

class MessageViewController: UIViewController, UITableViewDataSource {

    private let defaultInputBorderColor : UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    private let errorBordercolor: UIColor = UIColor(red: 198/255, green: 0, blue: 42/255, alpha: 1.0)
    
    @IBOutlet weak var senderName: UITextField!
    
    @IBOutlet weak var saveSenderNameButton: UIButton!
    @IBAction func saveSenderName(_ sender: Any) {
        guard let string = senderName.text else { return }
        
        if (string.isEmpty) {
            senderNameErrorLabel.text = "sender_name_field_empty".localized()
            senderName.layer.borderColor = errorBordercolor.cgColor
        } else {
            senderNameErrorLabel.text = ""
            senderName.layer.borderColor = defaultInputBorderColor.cgColor
            
            UserDefaults.standard.set(senderName.text!, forKey: "userName")
            
            self.showToast(message: "sender_name_saved".localized(), errorCode: 200, warning: false, hideAfter: 5.0, toastLocation: UIViewController.toastTop)
        }
    }
    
    @IBOutlet weak var senderNameErrorLabel: UILabel!
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
        guard let content = message.text else { return }
        
        if (content.isEmpty) {
            messageErrorLabel.text = "message_field_empty".localized()
            message.layer.borderColor = errorBordercolor.cgColor
        } else {
            messageErrorLabel.text = ""
            message.layer.borderColor = defaultInputBorderColor.cgColor
            message.text = ""
            
            postNewMessage(content: content)
        }
    }
    
    @IBOutlet weak var messageErrorLabel: UILabel!
    
    private var messages = [Message]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.superview?.bringSubview(toFront: tableView)

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
        
        retrieveSentMessages()
    }
    
    
    /**
     Retrieve messages that were already sent to the boat
     */
    private func retrieveSentMessages() {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        // Retrieve the coordinates when there is an active race
        if(accessToken != "") {
            let headers: HTTPHeaders = [
                "X-Access-Token": accessToken,
                "Accept": "application/json"
            ]
            
            messages = []
            
            Alamofire.request("\(AppStartHelper.apiURL)/apiv2/messages", headers: headers).responseJSON { response in                
                if let result = response.result.value as? NSArray {
                    let dateFormatterOld = DateFormatter()
                    dateFormatterOld.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    let dateFormatterNew = DateFormatter()
                    dateFormatterNew.dateFormat = "dd-MM HH:mm"
                    
                    for (_, object) in result.enumerated() {
                        if let message = object as? [String:Any] {
                            let sender = message["sender_name"] as! String
                            let content = message["message"] as! String
                            let timestamp = message["timestamp"] as! String
                            
                            let date = dateFormatterOld.date(from: timestamp)
                            
                            self.messages.append(Message(date: dateFormatterNew.string(from: date!), from: sender, message: content))
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }
    
    
    /**
     Post a new message
     */
    private func postNewMessage(content: String) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        // Retrieve the coordinates when there is an active race
        if(accessToken != "") {
            let headers: HTTPHeaders = [
                "X-Access-Token": accessToken,
                "Accept": "application/json"
            ]
            
            let parameters = [
                "device_uuid": UIDevice.current.identifierForVendor?.uuidString as Any,
                "sender_name": UserDefaults.standard.string(forKey: "userName")!,
                "message": content
            ]
        
            Alamofire.request("\(AppStartHelper.apiURL)/apiv2/messages", method: .post, parameters: parameters, headers: headers).responseJSON { response in
                if let result = response.result.value as? [String:Any] {
                    if(result["error"] as? Bool == false) {
                        let date = Date()
                        let calendar = Calendar.current
                        let day = calendar.component(.day, from: date)
                        let month = calendar.component(.month, from: date)
                        let hour = calendar.component(.hour, from: date)
                        let minutes = calendar.component(.minute, from: date)
                        
                        self.messages.append(Message(date: "\(day)-\(month) \(hour):\(minutes)", from: UserDefaults.standard.string(forKey: "userName")!, message: content))
                        
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            }
        }
    }
    
    
    /**
     Scroll to the bottom of the tableview
     */
    private func scrollToBottom(){
        if(self.messages.count > 0) {
            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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
        
        cell.senderName.text = message.from.uppercased()
        cell.date.text = message.date
        cell.message.text = message.message
        
        if(indexPath.row % 2 == 0) {
            cell.contentView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        }
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
