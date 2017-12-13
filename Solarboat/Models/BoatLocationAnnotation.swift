//
//  BoatLocation.swift
//  Solarboat
//
//  Created by Thomas Roovers on 05-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import MapKit

class BoatLocationAnnotation: NSObject, MKAnnotation {
    var boatLocation : BoatLocation
    var coordinate : CLLocationCoordinate2D { return boatLocation.location }
    let identifier : String = "boatLocationAnnotation"
    
    init(boatLocation: BoatLocation) {
        self.boatLocation = boatLocation
    }
    
    var title: String? {
        return ""
    }
    
    var subtitle: String? {
        return ""
    }
}
