//
//  PWVASTCompanion.swift
//  Phunware
//
//  Copyright © 2019 Phunware. All rights reserved.
//

import Foundation

class PWVASTCompanion {
    public var staticResource:String?
    public var htmlResource:String?
    public var trackingEvents:[String : String]?
    public var clickThrough:String?
    public var width:Int? = 0
    public var height:Int? = 0
    
    public init(){
        self.staticResource = nil
        self.trackingEvents = nil
        self.clickThrough = nil
        self.htmlResource = nil
    }
    
    public init(staticResource:String, trackingEvents:[String : String], clickThrough:String){
        self.staticResource = staticResource
        self.trackingEvents = trackingEvents
        self.clickThrough = clickThrough
    }
    
    public init(htmlResource:String, trackingEvents:[String: String], clickThrough:String){
        self.htmlResource = htmlResource
        self.trackingEvents = trackingEvents
        self.clickThrough = clickThrough
    }
}
