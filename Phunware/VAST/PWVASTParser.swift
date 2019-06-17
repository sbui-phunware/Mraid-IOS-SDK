//
//  VASTParser.swift
//  Phunware
//
//  Copyright © 2019 Phuwnare. All rights reserved.
//

import Foundation

class PWVASTParser : NSObject, XMLParserDelegate {
    private var companions:[PWVASTCompanion] = []
    private var currentCompanion:PWVASTCompanion?
    private var currentElement:String?
    private var currentEvent:String?
    private var videoPlayer:PWVideoPlayer!
    
    init(videoPlayer:PWVideoPlayer){
        self.videoPlayer = videoPlayer
        super.init()
    }
    
    internal func parseXML(_ xml:String){
        let data = xml.data(using: .utf8)
        if(data != nil){
            let xoc = XMLParser(data: data!)
            xoc.delegate = self
            xoc.parse()
        }
    }
    
    private func findBestCompanion() -> PWVASTCompanion? {
        let fsRect = CGSize(width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
        let aspectRatio = fsRect.width / fsRect.height
        var closestRatio:CGFloat = 0.0
        var curBest:PWVASTCompanion? = nil
        self.companions.forEach({c in
            let w = c.width!
            let h = c.height!
            let r = CGFloat(w) / CGFloat(h)
            if(closestRatio == 0.0 || (abs(aspectRatio - r) < closestRatio)){
                closestRatio = r
                curBest = c
            }
        })
        return curBest
    }
    
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    public func parserDidEndDocument(_ parser: XMLParser){
        if(self.videoPlayer != nil){
            self.videoPlayer!.endCardCompanion = findBestCompanion()
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentElement = elementName
        if(elementName == "Companion"){
            currentCompanion = PWVASTCompanion()
            let w = attributeDict["width"]
            let h = attributeDict["height"]
            
            if(w != nil){
                currentCompanion!.width = Int(w!)
            }
            if(h != nil){
                currentCompanion!.height = Int(h!)
            }
        }
        if(self.videoPlayer != nil){
            if(elementName == "Linear"){
                let so = attributeDict["skipoffset"]
                if(so == nil){
                    OperationQueue.main.addOperation{
                        self.videoPlayer.addCloseButton()
                    }
                }
            }
            if(elementName == "Tracking"){
                currentEvent = attributeDict["event"]
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(elementName == "Companion"){
            self.companions.append(self.currentCompanion!)
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines)
        if(!data.isEmpty){
            if(currentCompanion != nil){
                switch(self.currentElement){
                case "StaticResource":
                    self.currentCompanion?.staticResource = string
                case "Tracking":
                    if(currentCompanion?.trackingEvents == nil){
                        currentCompanion?.trackingEvents = [String:String]()
                    }
                    self.currentCompanion?.trackingEvents![currentEvent!] = string
                case "CompanionClickThrough":
                    self.currentCompanion?.clickThrough = string
                default:
                    break
                }
            }
        }
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parse failed")
    }
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print("validation failed")
    }
}