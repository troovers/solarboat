//
//  MapViewController.swift
//  Solarboat
//
//  Created by Thomas Roovers on 10-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import UIKit
import MapKit
import youtube_ios_player_helper
import Pulsator
import Alamofire
import SwiftyPlistManager

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, YTPlayerViewDelegate {
    
    var currentLocationAnnotation: BoatLocationAnnotation?
    
    var previousLocations: [PreviousBoatLocationAnnotation]?

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var menuCollapsed: Bool = false
    
    @IBAction func menuButton(_ sender: Any) {
        // Collapse or expand the tableview
        UIView.animate(withDuration: 0.3, animations: {
            if(self.menuCollapsed) {
                self.tableView.frame.origin.x += self.tableView.frame.size.width
                self.menuCollapsed = false
            } else {
                self.tableView.frame.origin.x -= self.tableView.frame.size.width
                self.menuCollapsed = true
            }
        }, completion: nil)
    }
    
    @IBOutlet weak var liveFeed: YTPlayerView!
    
    @IBOutlet weak var liveFeedButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Launch the startup helper
        let appStartHelper = AppStartHelper()
        
        mapView.delegate = self
        tableView.dataSource = self
        liveFeed.delegate = self
        
        // Register the settings bundle
        registerSettingsBundle()
        
        // Add the observer to watch for changes in the settings, whether or not to display the live feed
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        // Set the default value for displaying the live feed
        defaultsChanged()
        
        // Bring the table view to the front
        tableView.superview?.bringSubview(toFront: tableView)
        
        // Set the image for the live feed button
        liveFeedButton.imageView?.contentMode = .scaleAspectFit
        liveFeedButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);


        // Generate the structure of the tableview with stub data
        data[0] = [
            "type": "header",
            "text": "BOOT"
        ]
        
        data[1] = [
            "type": "info",
            "asset": "speed",
            "text": "0 km/h"
        ]
        
        data[2] = [
            "type": "info",
            "asset": "speed",
            "text": ""
        ]
        
        data[3] = [
            "type": "header",
            "text": "WEER"
        ]
        
        data[4] = [
            "type": "info",
            "asset": "windSpeed",
            "text": "0 km/h"
        ]
        
        data[5] = [
            "type": "info",
            "asset": "windDirection",
            "text": ""
        ]
        
        data[6] = [
            "type": "info",
            "asset": "temperature",
            "text": "0 \u{00B0}"
        ]
        
        data[7] = [
            "type": "info",
            "asset": "rainDrops",
            "text": "0 mm/h"
        ]
        
        // Add the weather section
        tableData = data
        
        // Add the socket handlers
        addSocketHandlers()

        let eventHelper: EventHelper = EventHelper.instance
        
        eventHelper.events.listenTo(eventName: "retrieveCoordinates", action: self.retrieveBoatLocations)
        
        eventHelper.events.listenTo(eventName: "loadLiveStream", action: self.loadLiveStream)
        
        // Start the timer to update the weather
        self.updateWeather()
        
        Timer.scheduledTimer(timeInterval: 600.0, target: self, selector: Selector(("updateWeather")), userInfo: nil, repeats: true)
    }
    
    
    /**
     Generating the views for the annotations of the boat location
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view : MKAnnotationView
        
        if let annotation = annotation as? BoatLocationAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
            }
            
            view.image = #imageLiteral(resourceName: "boatLocationAnnotation")
            view.centerOffset = CGPoint(x: 0, y: (view.image?.size.height)! / -2);
            
            let pulsator = Pulsator()
            pulsator.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
            pulsator.animationDuration = 3.0
            pulsator.position = CGPoint(x: 12.5, y: 12.5)
            
            view.layer.addSublayer(pulsator)
            
            pulsator.start()
            
            return view
        } else {
            if let annotation = annotation as? PreviousBoatLocationAnnotation {
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                }
                
                view.image = #imageLiteral(resourceName: "previousBoatLocationAnnotation")
                view.centerOffset = CGPoint(x: 0, y: (view.image?.size.height)! / -2);
                
                return view
            }
        }

        return nil
    }
    
    
    /**
     Retrieve the boat locations from the api and display them on the map
     */
    private func retrieveBoatLocations() {
        var boatID: Int = 0
        var accessToken: String = ""
        
        boatID = UserDefaults.standard.integer(forKey: "activeBoatID")
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        // Retrieve the coordinates when there is an active race
        if(boatID > 0 && accessToken != "") {
            let headers: HTTPHeaders = [
                "X-Access-Token": accessToken,
                "Accept": "application/json"
            ]
            
            previousLocations = []
            
            Alamofire.request("\(AppStartHelper.apiURL)/apiv2/coordinates/\(boatID)", headers: headers).responseJSON { response in
                if let result = response.result.value as? NSArray {
                    var speed = 0.0
                    
                    for (index, object) in result.enumerated() {
                        if let coordinates = object as? [String:Any] {
                            let boatLocation = BoatLocation(latitude: coordinates["latitude"] as! Double, longitude: coordinates["longitude"] as! Double)
                            
                            // Add the marker as current location
                            if(index == 0) {
                                speed = coordinates["speed"] as! Double
                                
                                self.currentLocationAnnotation = BoatLocationAnnotation(boatLocation: boatLocation)
                            } else {
                                self.previousLocations?.append(PreviousBoatLocationAnnotation(boatLocation: boatLocation))
                            }
                        }
                    }
                    
                    if(self.previousLocations?.count != 0) {
                        self.mapView.addAnnotations(self.previousLocations!)
                    }
                    
                    if(self.currentLocationAnnotation != nil) {
                        self.reloadRows(boatUpdate: BoatUpdate(rpm: 0.0, speed: speed))
                        
                        self.mapView.addAnnotation(self.currentLocationAnnotation!)
                        
                        // Move the map to zoom in on the last added location
                        let visibleRegion = MKCoordinateRegionMakeWithDistance((self.currentLocationAnnotation?.boatLocation.location)!, 5000, 5000)
                        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
                    }
                }
            }
        }
    }
    
    
    /**
     Add a new location to the map
     */
    private func addNewBoatLocation(boatLocation: BoatLocation) {
        // Delete the current boat location from the map
        mapView.removeAnnotation(currentLocationAnnotation!)
        
        // Add the previous current location to the map as a history location
        mapView.addAnnotation(PreviousBoatLocationAnnotation(boatLocation: currentLocationAnnotation!.boatLocation))
        
        self.currentLocationAnnotation = BoatLocationAnnotation(boatLocation: boatLocation)
        
        // Add the new location to the map as current location
        mapView.addAnnotation(self.currentLocationAnnotation!)
        
        // Move the map to zoom in on the last added location
        //mapView.setCenter(boatLocation.location, animated: true)
    }
    
    
    /**
     Load the live stream of the boat
     */
    private func loadLiveStream() {
    
        let channelId = UserDefaults.standard.string(forKey: "youtubeChannelId")
        
        let url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(channelId!)&type=video&eventType=live&key=AIzaSyCr5iItkEnieYuJpXnn9OacTTQ3PFPqW4c"
        
        Alamofire.request(url).responseJSON { response in
            var live: Bool = false
            var videoId: String?
            
            if let result = response.result.value as? [String:Any] {
                if let items = result["items"] as? NSArray {
                    if let liveStream = items[0] as? [String:Any] {
                        let id = liveStream["id"] as! [String:Any]
                        
                        live = true
                        
                        videoId = id["videoId"] as? String
                    }
                }
            }
            
            if (live) {
                // Remove the button overlay and play the video
                self.liveFeed.load(withVideoId: videoId!, playerVars: ["autoplay": 1, "live": 1, "modestbranding": 0, "showinfo": 0, "rel": 0, "playsinline" : 1, "controls" : 0])
            }
        }
    }
    
    
    /**
     Update the weather via the Buienradar API
     */
    private func updateWeather() {
        Alamofire.request("https://api.buienradar.nl/data/public/1.1/jsonfeed").responseJSON { response in
            guard let result = response.result.value as? [String:Any] else { return }
            guard let buienradar = result["buienradarnl"] as? [String:Any] else { return }
            guard let weergegevens = buienradar["weergegevens"] as? [String:Any] else { return }
            guard let actueel = weergegevens["actueel_weer"] as? [String:Any] else { return }
            guard let weerstations = actueel["weerstations"] as? [String:Any] else { return }
            guard let weerstation = weerstations["weerstation"] as? NSArray else { return }
            
            for (_, object) in weerstation.enumerated() {
                if let station = object as? [String:Any] {
                    // Check if the station is Leeuwarden (the closest to Akkrum)
                    if(station["stationcode"] as! String == "6270") {
                        
                        if let windSpeed = (Double(station["windsnelheidMS"] as! String)! / 3.6) as? Double {
                            self.tableData[4]?.updateValue("\(String(format: "%.1f", windSpeed)) km/h", forKey: "text")
                        }
                        
                        self.tableData[5]?.updateValue("\(station["windrichting"]!)", forKey: "text")
                        self.tableData[6]?.updateValue("\(station["temperatuur10cm"]!) \u{00B0}", forKey: "text")
                        
                        var rain = 0.0
                        
                        if let rainMM = Double(station["regenMMPU"] as! String) {
                            rain = rainMM
                        }
                        
                        self.tableData[7]?.updateValue("\(String(format: "%.1f", rain)) mm/h", forKey: "text")
                        
                        self.tableView.reloadRows(at: [IndexPath(item: 4, section: 0), IndexPath(item: 5, section: 0), IndexPath(item: 6, section: 0), IndexPath(item: 7, section: 0)], with: .none)
                        
                        return
                    }
                }
            }
        }
    }
    
    
    /**
     The function which get's called when the youtube player view is ready
     */
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.liveFeed.playVideo()
        
        self.liveFeedButton.setImage(nil, for: .normal)
        self.liveFeedButton.layer.backgroundColor = nil
    }
    
    
    /**
     Add the handlers for the socket connection
     */
    private func addSocketHandlers() {
        let client = SocketHelper.instance.client
        
        client?.on("boatUpdate") {data, ack in
            
            let object = data[0] as! [String:Any]
            
            if let boatUpdate = object["boatUpdate"] as? [String:Any] {
                let rpm = boatUpdate["rpm"] as! Double
                let speed = boatUpdate["speed"] as! Double
                
                var latitude = 0.0
                var longitude = 0.0
                
                if let location = boatUpdate["location"] as? [String:Double] {
                    latitude = location["latitude"]!
                    longitude = location["longitude"]!
                }
                
                let boatLocation = BoatLocation(latitude: latitude, longitude: longitude)
                
                self.addNewBoatLocation(boatLocation: boatLocation)
                
                let boatUpdate = BoatUpdate(rpm: rpm, speed: speed)
                
                self.reloadRows(boatUpdate: boatUpdate)
            }
        }
    }
    
    
    /**
     Reload the rows after a boatUpdate
     */
    func reloadRows(boatUpdate: BoatUpdate) {
        self.tableData[1]?.updateValue("\(boatUpdate.speed) km/h", forKey: "text")
        
        let indexPath = IndexPath(item: 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
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
            
            // Enlarge the live feed & button
            self.liveFeed.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.liveFeed.layoutSubviews()
            
            self.liveFeedButton.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.liveFeedButton.layoutSubviews()
            
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
            
            // The new size of the live feed & button
            self.liveFeed.transform = CGAffineTransform.identity
            self.liveFeed.frame = CGRect(x: x, y: y, width: 160, height: 90)
            self.liveFeed.layoutSubviews()
            
            self.liveFeedButton.transform = CGAffineTransform.identity
            self.liveFeedButton.frame = CGRect(x: x, y: y, width: 160, height: 90)
            self.liveFeedButton.layoutSubviews()
        }, completion: { (finished: Bool) in
            
        })
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
