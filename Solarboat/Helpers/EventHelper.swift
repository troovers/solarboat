//
//  Event.swift
//  Solarboat
//
//  Created by Thomas Roovers on 08-12-17.
//  Copyright © 2017 Thomas Roovers. All rights reserved.
//

class EventHelper {
    static let instance = EventHelper()
    
    let events = EventManager()
    
    func coordinatesCanBeRetrieved() {
        self.events.trigger(eventName: "retrieveCoordinates")
    }
    
    
    func liveStreamCanBeLoaded() {
        self.events.trigger(eventName: "loadLiveStream")
    }
}
