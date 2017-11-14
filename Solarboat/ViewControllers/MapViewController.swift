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

    @IBOutlet weak var navigationBar: UINavigationBar!
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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let sections : [Int: String] = [0: "BOOT", 1: "WEER"]
    var data = [Int: [String: String]]()
    var tableData = [Int: [Int: [String: String]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        tableView.dataSource = self
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage(named: "mapIcon"), for: .normal)
        self.navigationItem.titleView = button

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableData[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
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
