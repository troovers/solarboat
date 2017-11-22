//
//  TabBarViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 11-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Register the settings bundle
        registerSettingsBundle()
        
        // Add the observer to watch for changes in de password
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        // Set the defaults
        defaultsChanged()
    }
    
    
    /**
     Register the settings bundle
     */
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    /**
     The settings have been altered, check to see if we need to remove or show the livefeed
     */
    @objc func defaultsChanged(){
        // Get the password from the settings
        let password = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.teamPassword)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Check if the password is correct
        if password == "password" {
            // Add the tab bar item if the password is correct
            if self.tabBar.items?.count == 3 {
                // Instantiate the message viewcontroller
                let messageViewController = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                self.viewControllers?.append(messageViewController)
                
                // Configure the tab bar item
                let tabBarItem = self.tabBar.items![3]
                tabBarItem.image = UIImage(named: "messageIcon")
                tabBarItem.title = "Berichten"
            }
        } else {
            // If there are four items, remove the message tab
            if self.tabBar.items?.count == 4 {
                self.viewControllers?.remove(at: 3)
            }
            
            // If the password is not empty and not nil, the user filled in a wrong password
            if(password != "" && password != nil) {
                // Show the user that the password is incorrect
                let viewController: UIViewController = getTopViewController()
                
                viewController.showToast(message: "Het team wachtwoord is incorrect", errorCode: 403, warning: true, hideAfter: 5.0)
                
                // Remove the provided password from the settings
                UserDefaults.standard.set(nil, forKey: SettingsBundleHelper.SettingsBundleKeys.teamPassword)
            }
        }
    }
    
    
    /**
     Get the top / current view controller to display the toast message on
     */
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
    
    
    /**
     This function handles the select event on a tab
     */
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // If the third item is tapped, we want to naviagte to the settings app instead of opening the page
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
