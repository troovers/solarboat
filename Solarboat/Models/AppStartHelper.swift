//
//  AppStartupHelper.swift
//  Solarboat
//
//  Created by Thomas Roovers on 13-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import Alamofire

class AppStartHelper {
    
    init() {
        self.login()
        
        self.initiateSocketConnection()
    }
    
    
    /**
     Log the user in, to retrieve the access token
     */
    private func login() {
        let parameters = ["username": "solarboat", "password": "solarboat12345"]
        
        Alamofire.request("http://localhost:9100/apiv2/login", method: .post, parameters: parameters).responseJSON { response in
            if let result = response.result.value as? [String:Any] {
                UserDefaults.standard.set(result["token"] as! String, forKey: "accessToken")
                
                self.getActiveBoat(accessToken: result["token"] as! String)
            }
        }
    }
    
    
    /**
     Get the active boat
     */
    private func getActiveBoat(accessToken: String) {
        let headers: HTTPHeaders = [
            "X-Access-Token": accessToken,
            "Accept": "application/json"
        ]
        
        Alamofire.request("http://localhost:9100/apiv2/boats/active", headers: headers).responseJSON { response in
            if let result = response.result.value as? NSArray {
                if let boat = result[0] as? [String:Any] {
                    UserDefaults.standard.set(boat["id"] as! Int, forKey: "activeBoatID")
                    
                    UserDefaults.standard.set(boat["youtube_channel_id"] as! String, forKey: "youtubeChannelId")
                    
                    let eventHelper: EventHelper = EventHelper.instance
                    
                    eventHelper.coordinatesCanBeRetrieved()
                    eventHelper.liveStreamCanBeLoaded()
                }
            }
        }
    }
    
    
    /**
     Initiate the Socket connection with the server
     */
    private func initiateSocketConnection() {
        let client = SocketHelper.instance.client
        
        client?.on(clientEvent: .connect) {data, ack in
            // Socket is connected
            let deviceInfo = [
                "app": true,
                "uuid": UIDevice.current.identifierForVendor?.uuidString as Any,
                "name": UIDevice.current.name,
                "model": UIDevice.current.model,
                "systemVersion": UIDevice.current.systemVersion,
                "platform": "ios",
                "appVersion": UserDefaults.standard.string(forKey: "APP_VERSION")
                ] as [String : Any]
            
            client?.emit("registerDevice", deviceInfo)
        }
        
        SocketHelper.instance.establishConnection()
    }
}
