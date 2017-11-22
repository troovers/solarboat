//
//  MapViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 10-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var menuCollapsed: Bool = false
    
    @IBAction func menuButton(_ sender: Any) {
        // Collapse or expand the tableview
        
        UIView.animate(withDuration: 0.3, animations: {
            if(self.menuCollapsed) {
                self.tableView.frame.origin.x += 100
                self.menuCollapsed = false
            } else {
                self.tableView.frame.origin.x -= 100
                self.menuCollapsed = true
            }
        }, completion: nil)
    }
    
    @IBOutlet weak var liveFeed: UIButton!
    
    var liveFeedIsExpanded: Bool = false
    
    @IBAction func liveFeed(_ sender: Any) {
        
        if !liveFeedIsExpanded {
            expandLiveFeed()
        } else {
            shrinkLiveFeed()
        }
        
        liveFeedIsExpanded = !liveFeedIsExpanded
    }    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewTabBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let sections : [Int: String] = [0: "BOOT", 1: "WEER"]
    var data = [Int: [String: String]]()
    var tableData = [Int: [Int: [String: String]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSettingsBundle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        defaultsChanged()
        
        mapView.delegate = self
        
        tableView.dataSource = self
        
        // Bring the table view to the front
        tableView.superview?.bringSubview(toFront: tableView)

        // Do any additional setup after loading the view.
        data[0] = [
            "asset": "speed",
            "text": "5 km/h"
        ]
        
        data[1] = [
            "asset": "speed",
            "text": "text"
        ]
        
        tableData[0] = data
        
        data[0] = [
            "asset": "windSpeed",
            "text": "1 km/h"
        ]
        
        data[1] = [
            "asset": "windDirection",
            "text": "NO"
        ]
        
        data[2] = [
            "asset": "temperature",
            "text": "15 \u{00B0}"
        ]
        
        tableData[1] = data
        
        let when = DispatchTime.now() + 10 
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.tableData[1]![0]?.updateValue("10 km/h", forKey: "text")
            
            let indexPath = IndexPath(item: 0, section: 1)
            self.tableView.reloadRows(at: [indexPath], with: .top)
        }
    }
    
    
    // Register the settings bundle to check for changes
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    // The settings have been altered, check to see if we need to remove or show the livefeed
    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: SettingsBundleHelper.SettingsBundleKeys.displayLivefeed) {
            self.liveFeed.isHidden = false
        } else {
            self.liveFeed.isHidden = true
            
            if liveFeedIsExpanded {
                shrinkLiveFeed()
                
                liveFeedIsExpanded = false
            }
        }
    }
    
    
    // Expand the livefeed
    func expandLiveFeed() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let mapViewFrame = mapView.frame
        let height = self.view.frame.width * 9 / 16
        
        //Expand the video
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y = self.view.frame.height - height - tabBarHeight!
            
            self.liveFeed.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.liveFeed.layoutSubviews()
            
            self.mapView.frame = CGRect(x: 0, y: mapViewFrame.origin.y, width: self.view.frame.width, height: self.view.frame.height - height)
            self.mapView.layoutSubviews()
            
        }, completion: { (finished: Bool) in
            
        })
    }
    
    
    // Shrink the livefeed
    func shrinkLiveFeed() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let mapViewFrame = mapView.frame
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.mapView.frame = CGRect(x: 0, y: mapViewFrame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            self.mapView.layoutSubviews()
            
            let x = self.view.frame.width - 160
            let y = self.view.frame.height - 90 - tabBarHeight!
            
            self.liveFeed.transform = CGAffineTransform.identity
            self.liveFeed.frame = CGRect(x: x, y: y, width: 160, height: 90)
            self.liveFeed.layoutSubviews()
        }, completion: { (finished: Bool) in
            
        })
    }
    
    
    func longPressOnLiveFeed() {
        // Navigate to the video of the teams
        
        performSegue(withIdentifier: "showTemVideoSegue", sender: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Set the number of sections in the tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // Set the number of rows in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableData[section]?.count)!
    }
    
    
    // Set the title for the section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    
    // Generate the cell for the index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BoatInformationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "boatInformationTableCell", for: indexPath) as! BoatInformationTableViewCell
        
        for (key, value) in tableData[indexPath.section]![indexPath.row]! {
            if(key == "asset") {
                cell.icon?.image = UIImage(named: value)
            } else {
                cell.label?.text = value
            }
        }
        
        return cell
    }
    
    
    // Style the sections of the tableview
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        
        return headerView
    }
    
    
    // Set the height for the section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    // Not needed for iOS9 and above. ARC deals with the observer in higher versions.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
