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
    private var originalRootController:UIViewController!
    let fullScreenSize = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
    
    public func initialize(onClose:@escaping () -> Void){
        self.originalRootController = UIApplication.shared.delegate?.window??.rootViewController
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.init(rawValue: 0)
        self.onClose = onClose
        videoView = WKWebView(frame:fullScreenSize, configuration:config)
        view.autoresizesSubviews = true
        view.isUserInteractionEnabled = true
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        videoView!.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        videoView!.uiDelegate = self
        videoView!.navigationDelegate = self
        addCloseButton()
        view.addSubview(videoView!)
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    private func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Capture window.open (clickthroughs) and redirect
        webView.load(navigationAction.request)
        return nil
    }
    
    /* Handle HTTP requests from the webview */
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if(url != nil && url != "about:blank"){
            let browser = MRAIDBrowserWindow()
            browser.initialize()
            browser.loadUrl(url!)
            browser.onClose(perform:{() in
                MRAIDUtilities.setRootController(self.originalRootController!)
            })
            MRAIDUtilities.setRootController(browser)
        }
        decisionHandler(.allow)
        return
    }
    
    public func playVideo(_ url:URL, onClose:@escaping () -> Void){
        self.initialize(onClose:onClose);
        let request:URLRequest = URLRequest(url:url)
        videoView!.load(request)
    }
    
    public func playHTMLVideo(_ body:String, onClose:@escaping() -> Void){
        self.initialize(onClose:onClose)
        videoView!.loadHTMLString(body, baseURL:nil)
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
