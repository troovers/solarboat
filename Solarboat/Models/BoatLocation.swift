//
//  BoatLocation.swift
//  Solarboat
//
//  Created by Thomas Roovers on 08-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import MapKit

class BoatLocation {
    var location: CLLocationCoordinate2D
    
    init(latitude: Double, longitude: Double) {
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
