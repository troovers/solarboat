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
    
    /// The data structure of the information
    var data = [Int: [String: String]]()
    
    /// The complete set of data for inside the tableview
    var tableData = [Int: [String: String]]()
    
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
            "type": "header",
            "text": "BOOT"
        ]
        
        data[1] = [
            "type": "info",
            "asset": "speed",
            "text": "5 km/h"
        ]
        
        data[2] = [
            "type": "info",
            "asset": "speed",
            "text": "text"
        ]
        
        data[3] = [
            "type": "header",
            "text": "WEER"
        ]
        
        data[4] = [
            "type": "info",
            "asset": "windSpeed",
            "text": "1 km/h"
        ]
        
        data[5] = [
            "type": "info",
            "asset": "windDirection",
            "text": "NO"
        ]
        
        data[6] = [
            "type": "info",
            "asset": "temperature",
            "text": "15 \u{00B0}"
        ]
        
        // Add the weather section
        tableData = data
        
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
            
            socket.emit("boatUpdate", "")
            
            socket.emit("streamImage", "")
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
        
        socket.on("streamImage") {data, ack in
            let object = data[0] as! [String:Any]
            
            let image = object["image"] as? String
            
            //let encoded = image!.replacingOccurrences(of: "data:image/jpg;base64,/9j/", with: "")
            let encoded = image!

            if let decodedData = Data(base64Encoded: encoded, options: .ignoreUnknownCharacters) {
                let image = UIImage(data: decodedData)
                
                //self.liveFeed.setBackgroundImage(image, for: UIControlState.normal)

            }
        }
        
        socket.connect()
    }
    
    
    /**
     Reload the rows after a boatUpdate
     */
    func reloadRows(boatUpdate: BoatUpdate) {
        self.tableData[1]?.updateValue("\(boatUpdate.speed) km/h", forKey: "text")
        
        let indexPath = IndexPath(item: 1, section: 0)
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
        return 1
    }
    
    
    /**
     Set the number of rows in the tableview
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    /**
     Generate the cell for the index
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 || indexPath.row == 3 {
            let cell: BoatInformationHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "boatInformationHeaderTableCell", for: indexPath) as! BoatInformationHeaderTableViewCell
            
            let row = tableData[indexPath.row]! as [String:String]
            
            cell.headerTitle.text = row["text"]
            
            return cell
        } else {
            let cell: BoatInformationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "boatInformationTableCell", for: indexPath) as! BoatInformationTableViewCell
            
            let row = tableData[indexPath.row]! as [String:String]
            
            cell.icon?.image = UIImage(named: row["asset"]!)
            cell.label?.text = row["text"]
            
            return cell
        }
    }
    
    
    /**
     Deinitialize the view. Not needed for iOS9 and above. ARC deals with the observer in higher versions.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
