//
//  Message.swift
//  Solarboat
//
//  Created by Thomas Roovers on 25-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

class Message {
    var date: String
    var from: String
    var message: String
    
    init(date: String, from: String, message: String) {
        self.date = date
        self.from = from
        self.message = message
    }
}
