//
//  SocketHelper.swift
//  Solarboat
//
//  Created by Thomas Roovers on 13-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import SocketIO

class SocketHelper {
    static let instance = SocketHelper()
    
    private let socketManager: SocketManager = SocketManager(socketURL: URL(string: "http://127.0.0.1:9100")!, config: [.log(false), .compress])
    
    var client: SocketIOClient?
    
    init() {
        client = socketManager.defaultSocket
    }
    
    func establishConnection() {
        client?.connect()
    }
    
    func closeConnection() {
        client?.disconnect()
    }
}
