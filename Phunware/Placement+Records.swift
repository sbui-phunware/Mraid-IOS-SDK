//
//  Placement+Records.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation

public extension Placement {
    /// Sends request to record impression for this `Placement`.
    public func recordImpression() {
        if let accupixelUrl = self.accupixelUrl.flatMap({ URL(string: $0) }) {
            Phunware.requestPixel(with: accupixelUrl)
        }
        if let trackingPixel = self.trackingPixel.flatMap({ URL(string: $0) }) {
            Phunware.requestPixel(with: trackingPixel)
        }
        let impressionBeacons: [[String:String]]? = self.beacons?.filter{listOfDicts in
            return listOfDicts["impression"] != nil
        }
        impressionBeacons?.forEach{item in
            if let impressionBeacon = item["impression"].flatMap({URL(string: $0)}){
                Phunware.requestPixel(with: impressionBeacon)
            }
        }
    }
    
    /// Sends request to record click for this `Placement`.
    public func recordClick() {
        if(!self.clicked){
            self.clicked = true
            if let redirectUrl = self.redirectUrl.flatMap({ URL(string: $0) }) {
                Phunware.requestPixel(with: redirectUrl)
            } else {
                print("Cannot construct a valid redirect URL.")
            }
            let clickBeacons: [[String:String]]? = self.beacons?.filter{listOfDicts in
                return listOfDicts["type"] == "click"
            }
            clickBeacons?.forEach{item in
                if let impressionBeacon = item["url"].flatMap({URL(string: $0)}){
                    Phunware.requestPixel(with: impressionBeacon)
                }
            }
        }
    }
}
