//
//  TabBarViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 11-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private var firstPasswordCheck: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        registerSettingsBundle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        defaultsChanged()
    }
    
    
    // Register the settings bundle to check for changes
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    // The settings have been altered, check to see if we need to remove or show the livefeed
    @objc func defaultsChanged(){
        let password = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.teamPassword)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if password == "password" {
            // Add the tab bar item if the password is correct
            if self.tabBar.items?.count == 3 {                
                let messageViewController = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                self.viewControllers?.append(messageViewController)
                
                let tabBarItem = self.tabBar.items![3]
                tabBarItem.image = UIImage(named: "messageIcon")
                tabBarItem.title = "Berichten"
            }
        } else {
            //self.tabBar.items![3].isEnabled = false
            
            if self.tabBar.items?.count == 4 {
                self.viewControllers?.remove(at: 3)
            }
            
            if(password != "" && password != nil) {
                // Show the user that the password is incorrect
                let viewController: UIViewController = getTopViewController()
                
                viewController.showToast(message: "Het team wachtwoord is incorrect", errorCode: 403, warning: true, hideAfter: 5.0)
                
                // Remove the provided password from the settings
                UserDefaults.standard.set(nil, forKey: SettingsBundleHelper.SettingsBundleKeys.teamPassword)
            }
        }
        
        firstPasswordCheck = false
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // this provides UI feedback that the button has been pressed, even though it leads to the dismissal
        if viewController == self.viewControllers![2] {
            // Navigate to the settings app
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return false
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
            
            return false
        } else {
            return true
        }
    }
}
