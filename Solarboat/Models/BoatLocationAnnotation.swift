//
//  BoatLocation.swift
//  Solarboat
//
//  Created by Thomas Roovers on 05-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import MapKit

class BoatLocationAnnotation: NSObject, MKAnnotation {
    var boatUpdate : BoatUpdate
    var coordinate : CLLocationCoordinate2D { return boatUpdate.location }
    let identifier : String = "boatLocationAnnotation"
    
    init(boatUpdate: BoatUpdate) {
        self.boatUpdate = boatUpdate
    }
    
    var title: String? {
        return ""
    }
    
    var subtitle: String? {
        return ""
    }
}
