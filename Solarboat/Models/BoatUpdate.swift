//
//  BoatUpdate.swift
//  Solarboat
//
//  Created by Thomas Roovers on 23-11-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

import MapKit

class BoatUpdate {
    var rpm: Double
    var speed: Double
    var location: CLLocationCoordinate2D
    
    init(rpm: Double, speed: Double, latitude: Double, longitude: Double) {
        self.rpm = rpm
        self.speed = speed
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
