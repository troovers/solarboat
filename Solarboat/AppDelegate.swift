//
//  AppDelegate.swift
//  Solarboat
//
//  Created by Thomas Roovers on 09-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyPlistManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var reachability: Reachability = Reachability()!
    private var connected: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 198/255, green: 23/255, blue: 42/255, alpha: 1)
        
        // Initialize a network connectivity observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        
        // Start the plist manager for easy editing
        SwiftyPlistManager.shared.start(plistNames: ["UserData"], logging: false)
        
        // Override point for customization after application launch.
        return true
    }
    
    // The internet connectivity has changed
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        let viewController: UIViewController = getTopViewController()
        
        // Check whether we have a connection to the internet
        switch reachability.connection {
            case .wifi:
                if !connected {
                    viewController.hideToast(tag: 500)
                }
                
                connected = true
            case .cellular:
                if !connected {
                    viewController.hideToast(tag: 500)
                }
                
                connected = true
            case .none:
                // Display a toast when the connection went dark
                if connected {
                    viewController.showToast(message: "Er is geen internetverbinding", errorCode: 500, warning: true, hideAfter: 0)
                    
                    connected = false
                }
        }
    }
    
    func getTopViewController() -> UIViewController {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return UIViewController()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
        SettingsBundleHelper.setVersionAndBuildNumber()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Stop observing changes in the connectivity
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }


}

