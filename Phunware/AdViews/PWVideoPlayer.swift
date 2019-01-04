//
//  PWVideoPlayer.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import WebKit

public class PWVideoPlayer: UIViewController, WKUIDelegate, WKNavigationDelegate {
    private var videoView:WKWebView?
    private var constraints:[NSLayoutConstraint]? = []
    private var onClose:() -> Void = {}
    let fullScreenSize = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
    public func playVideo(_ url:URL, onClose:@escaping () -> Void){
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        self.onClose = onClose
        videoView = WKWebView(frame:fullScreenSize, configuration:config)
        view.autoresizesSubviews = true
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        videoView!.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        videoView!.uiDelegate = self
        addCloseButton()
        view.addSubview(videoView!)
        let request:URLRequest = URLRequest(url:url)
        videoView!.load(request)
    }
    
    public func addCloseButton(){
        let w = videoView!.bounds.width
        let closeW = CGFloat(50)
        let closeH = CGFloat(50)
        
        let closeX = w - closeW
        let closeY = videoView!.bounds.minY + 3
        let buttonRect = CGRect(x:closeX, y:closeY, width:closeW, height:closeH)
        
        let closeButton = UIButton(frame:buttonRect)
        closeButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        closeButton.setTitleColor(UIColor.white, for:UIControlState.normal)
        closeButton.setBackgroundImage(UIImage(named:"closeButtonBG", in: Bundle(identifier:"phunware.ios.mraid.sdk"), compatibleWith:nil), for: UIControlState.normal)
        closeButton.setTitle("X", for:UIControlState.normal)
        closeButton.titleLabel!.textAlignment = NSTextAlignment.center
        closeButton.titleLabel!.font = UIFont.init(descriptor: UIFontDescriptor(name:"Gill Sans", size:24.0), size: 24.0)
    
        closeButton.addTarget(self, action: #selector(close), for:UIControlEvents.touchUpInside)
        videoView!.addSubview(closeButton)
    }
    
    @objc func close(){
        videoView!.removeFromSuperview()
        videoView = nil
        removeFromParentViewController()
        onClose()
    }
    
    public var webView:WKWebView {
        return videoView!
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        NSLog("Video view closed.")
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    }
}
