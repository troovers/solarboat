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
    var location: CLLocation
    
    init(rpm: Double, speed: Double, latitude: Double, longitude: Double) {
        self.rpm = rpm
        self.speed = speed
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
