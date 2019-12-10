//
//  PostMessageHandler.swift
//  Phunware
//
//  Created by Will Prevett on 2019-12-10.
//  Copyright © 2019 Will Prevett. All rights reserved.
//

import Foundation
import WebKit

class PostMessageHandler: NSObject, WKScriptMessageHandler{
    
    var vast:PWVASTVideo!
    
    func initialize(vast:PWVASTVideo) {
        self.vast = vast
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "vastPlayerMessageHandler", let messageBody = message.body as? [String:Any] {
            if let xml = messageBody["xml"] as? String {
                PWVASTParser(self.vast).parseXML(xml.decodeUrl()!)
            }
                
            if let event = messageBody["event"] as? String {
                print("Event: \(event)")
                self.vast.handleEvent(event)
            }
        }
    }
}
