//
//  MapViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 10-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import MapKit
import SocketIO

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
    
    /// The sections which are going to display the boat and weather info
    let sections : [Int: String] = [0: "BOOT", 1: "WEER"]
    
    /// The data structure of the information
    var data = [Int: [String: String]]()
    
    /// The complete set of data for inside the tableview
    var tableData = [Int: [Int: [String: String]]]()
    
    private let socketManager: SocketManager = SocketManager(socketURL: URL(string: "http://icytea.nl")!, config: [.log(true), .compress])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        tableView.dataSource = self
        
        // Register the settings bundle
        registerSettingsBundle()
        
        // Add the observer to watch for changes in the settings, whether or not to display the live feed
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        // Set the default value for displaying the live feed
        defaultsChanged()
        
        // Bring the table view to the front
        tableView.superview?.bringSubview(toFront: tableView)

        // Generate the structure of the tableview with stub data
        data[0] = [
            "asset": "speed",
            "text": "5 km/h"
        ]
        
        data[1] = [
            "asset": "speed",
            "text": "text"
        ]
        
        // Add the boat section
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
        
        // Add the weather section
        tableData[1] = data
        
        // Add the socket handlers
        addSocketHandlers()
    }
    
    
    /**
     Add the handlers for the socket connection
     */
    func addSocketHandlers() {
        let socket = socketManager.defaultSocket

        socket.on(clientEvent: .connect) {data, ack in
            // Socket is connected
            
            socket.emit("registerDevice", ["text"])
            
            socket.emit("fakeUpdate", "")
        }
        
        socket.on("boatUpdate") {data, ack in
            
            let object = data[0] as! [String:Any]
            
            if let boatUpdate = object["info"] as? [String:Any] {
                let rpm = boatUpdate["rpm"] as! Double
                let speed = boatUpdate["speed"] as! Double
                
                var latitude = 0.0
                var longitude = 0.0
                
                if let location = boatUpdate["location"] as? [String:String] {
                    latitude = Double(location["latitude"]!)!
                    longitude = Double(location["longitude"]!)!
                }
                
                let boatUpdate = BoatUpdate(rpm: rpm, speed: speed, latitude: latitude, longitude: longitude)
                
                self.reloadRows(boatUpdate: boatUpdate)
            }
        }
        
        socket.connect()
    }
    
    
    /**
     Reload the rows after a boatUpdate
     */
    func reloadRows(boatUpdate: BoatUpdate) {
        self.tableData[0]![0]?.updateValue("\(boatUpdate.speed) km/h", forKey: "text")
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .top)
    }
    
    
    /**
     Register the settings bundle to check for changes
     */
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    /**
     The settings have been altered, check to see if we need to remove or show the livefeed
     */
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
    
    
    /**
     Expand the livefeed
     */
    func expandLiveFeed() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let mapViewFrame = mapView.frame
        let height = self.view.frame.width * 9 / 16
        
        // Expand the video
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // The new y position of the live feed
            let y = self.view.frame.height - height - tabBarHeight!
            
            // Enlarge the live feed
            self.liveFeed.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.liveFeed.layoutSubviews()
            
            // Decrease the size of the mapview
            self.mapView.frame = CGRect(x: 0, y: mapViewFrame.origin.y, width: self.view.frame.width, height: self.view.frame.height - height)
            self.mapView.layoutSubviews()
            
        }, completion: { (finished: Bool) in
            
        })
    }
    
    
    /**
     Shrink the livefeed
     */
    func shrinkLiveFeed() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let mapViewFrame = mapView.frame
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // Enlarge the mapview to its' original size
            self.mapView.frame = CGRect(x: 0, y: mapViewFrame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            self.mapView.layoutSubviews()
            
            // The new position of the live feed
            let x = self.view.frame.width - 160
            let y = self.view.frame.height - 90 - tabBarHeight!
            
            // The new size of the live feed
            self.liveFeed.transform = CGAffineTransform.identity
            self.liveFeed.frame = CGRect(x: x, y: y, width: 160, height: 90)
            self.liveFeed.layoutSubviews()
        }, completion: { (finished: Bool) in
            
        })
    }
    
    
    /**
     Handle a long press on the live feed as an easter egg
     */
    func longPressOnLiveFeed() {
        // Navigate to the video of the teams
        performSegue(withIdentifier: "showTeamVideoSegue", sender: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Set the number of sections in the tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    /**
     Set the number of rows in the tableview
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableData[section]?.count)!
    }
    
    
    /**
     Set the title for the section
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    
    /**
     Generate the cell for the index
     */
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
    
    
    /**
     Style the sections of the tableview
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        
        return headerView
    }
    
    
    /**
     Set the height for the section header
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    /**
     Deinitialize the view. Not needed for iOS9 and above. ARC deals with the observer in higher versions.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
