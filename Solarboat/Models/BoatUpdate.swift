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
    
    init(rpm: Double, speed: Double) {
        self.rpm = rpm
        self.speed = speed
    }
}
