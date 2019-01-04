//
//  ABImageView.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import UIKit
import Foundation

public class PWBannerView: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    public var placement: Placement?
    public var webView: UIWebView!
    private var tapped: Bool = false
    
    
    public func loadHTMLBanner(body:String!, frame:CGRect){
        webView = UIWebView(frame: frame)
        webView.delegate = self
        webView.dataDetectorTypes = UIDataDetectorTypes.all
        
        webView.isOpaque = true
        webView.isUserInteractionEnabled = true
        webView.loadHTMLString(body, baseURL:nil)
        webView.scrollView.contentInset = UIEdgeInsetsMake(-8.0, -8.0, 8, 8)
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:nil)
        gesture.delegate = self
        webView.addGestureRecognizer(gesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UITapGestureRecognizer) {
            tapped = true
            return true
        } else {
            return false
        }
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        let url = request.url
        if(url != nil && url!.absoluteString != "about:blank"){
            if(
                url!.absoluteString.range(of:"ssp-r.phunware.com") != nil){
                return true
            }else if(tapped){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url!)
                }
                self.placement?.recordClick()
                tapped = false
                return false
            }
        }
        return true
    }
}
