//
//  SettingsBundleHelper.swift
//  Solarboat
//
//  Created by Thomas Roovers on 22-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        /// Settings key for displaying the live feed
        static let displayLivefeed = "DISPLAY_LIVEFEED"
        static let teamPassword = "TEAM_PASSWORD"
        static let centerBoatOnMap = "CENTER_BOAT_ON_MAP"
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "APP_VERSION")
        
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "APP_BUILD")
        
        if(!UserDefaults.standard.bool(forKey: "launchedBefore")) {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            // Set the default values for the booleans
            UserDefaults.standard.set(true, forKey: SettingsBundleKeys.displayLivefeed)
            UserDefaults.standard.set(true, forKey: SettingsBundleKeys.centerBoatOnMap)
        }
    }
}
