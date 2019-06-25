//
//  PWVideoPlayer.swift
//   Phunware

//  Copyright © 2018 Phunware, Inc. All rights reserved.

import Foundation
import WebKit


public class PWVideoPlayer: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    private var videoView:WKWebView?
    private var constraints:[NSLayoutConstraint]? = []
    private var onClose:() -> Void = {}
    private var originalRootController:UIViewController!
    let fullScreenSize = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
    private var delegate:PWVASTDelegate?
    
    internal var endCardCompanion:PWVASTCompanion? = nil
    internal var addCloseButtonToVideo = true
    
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
        if(url != nil && !url!.starts(with:"about:blank") && url! != "https://ssp-r.phunware.com/"){
            if (url!.range(of:"itunes.apple.com") != nil){
                if let url = URL(string: url!), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            else if (url!.range(of:"vast://") != nil){
                if(url!.range(of:"vastresponse?xml=") != nil){
                    let range = url!.range(of:"vast://vastresponse?xml=")
                    let from = range?.upperBound
                    let to = url!.endIndex
                    let xml = String(url![from!..<to])
                    PWVASTParser(videoPlayer: self).parseXML(xml.decodeUrl()!)
                }else{
                    let range = url!.range(of:"vast://")
                    let from = range?.upperBound
                    let to = url!.endIndex
                    let event = String(url![from!..<to])
                    handleEvent(event)
                }
            }else if (url!.range(of:"callback.spark") == nil && url!.range(of:"callback-p.spark") == nil){
                let browser = MRAIDBrowserWindow()
                browser.initialize()
                browser.loadUrl(url!)
                browser.onClose(perform:{() in
                    MRAIDUtilities.setRootController(self.originalRootController!)
                })
                MRAIDUtilities.setRootController(browser)
            }
        }
        decisionHandler(.allow)
        return
    }
    
    public func playVideo(_ url:URL, onClose:@escaping () -> Void){
        self.initialize(onClose:onClose);
        let request:URLRequest = URLRequest(url:url)
        videoView!.load(request)
        if(addCloseButtonToVideo){
            addCloseButton()
        }
    }
    
    public func playHTMLVideo(_ body:String, delegate:PWVASTDelegate?, onClose:@escaping() -> Void){
        self.initialize(onClose:onClose)
        self.delegate = delegate
        videoView!.loadHTMLString(body, baseURL:nil)
        if(addCloseButtonToVideo){
            addCloseButton()
        }
    }
    
    internal func addCloseButton(){
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
    
    private func displayEndCard(){
        let markup = getEndCardMarkup()
        webView.loadHTMLString(markup, baseURL:nil)
        handleEndCardEvents()
        addClickThroughToEndCard()
        addCloseButton()
    }
    
    private func addClickThroughToEndCard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.endCardClick (_:)))
        tap.delegate = self
        webView.addGestureRecognizer(tap)
    }
    
    private func handleEndCardEvents(){
        endCardCompanion?.trackingEvents!.forEach{ keyVal in
            if(keyVal.key == "creativeView"){
                let url = URL(string: keyVal.value)!
                let session = URLSession.shared
                let request = URLRequest(url: url)
                
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    guard error == nil else {
                        NSLog("Error reporting companion creative view")
                        return
                    }
                    
                    // no need to do anything here
                })
                task.resume()
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc
    func endCardClick(_ sender:UITapGestureRecognizer){
        if(endCardCompanion?.clickThrough != nil){
            if (endCardCompanion!.clickThrough!.range(of:"itunes.apple.com") != nil){
                if let url = URL(string: endCardCompanion!.clickThrough!), UIApplication.shared.canOpenURL(URL(string:endCardCompanion!.clickThrough!)!) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }else{
                let browser = MRAIDBrowserWindow()
                browser.initialize()
                browser.loadUrl(endCardCompanion!.clickThrough!)
                browser.onClose(perform:{() in
                    MRAIDUtilities.setRootController(self.originalRootController!)
                })
                MRAIDUtilities.setRootController(browser)
            }
        }
    }
    
    private func getEndCardMarkup() -> String{
        let markup = """
        <!DOCTYPE html>
        <html>
        <head>
        <style>
        body {
        background: url('\(endCardCompanion!.staticResource!)') no-repeat fixed;
        background-size: contain;
        background-position: center;
        }
        </style>
        </script>
        </head>
        <body style=\"background-color:black; margin:0; padding:0; font-size:0px; width:" + \(endCardCompanion!.width!) + "px; height:" + \(endCardCompanion!.height!) + "px;\">
        </div>
        <body>
        </html>
        """
        return markup
    }
    
    func handleEvent(_ event:String){
        switch(event){
        case "mute":
            self.delegate?.onMute()
        case "unmute":
            self.delegate?.onUnmute()
        case "pause":
            self.delegate?.onPause()
        case "resume":
            self.delegate?.onResume()
            
        case "rewind":
            self.delegate?.onRewind()
            
        case "skip":
            self.delegate?.onSkip()
            if(endCardCompanion != nil){
                displayEndCard()
            }else{
                close()
            }
        case "playerExpand":
            self.delegate?.onPlayerExpand()
            
        case "playerCollapse":
            self.delegate?.onPlayerCollapse()
            
        case "notUsed":
            self.delegate?.onNotUsed()
            
        case "loaded":
            self.delegate?.onLoaded()
            
        case "start":
            self.delegate?.onStart()
            
        case "firstQuartile":
            self.delegate?.onFirstQuartile()
            
        case "midpoint":
            self.delegate?.onMidpoint()
            
        case "thirdQuartile":
            self.delegate?.onThirdQuartile()
            
        case "complete":
            self.delegate?.onComplete()
            if(endCardCompanion != nil){
                displayEndCard()
            }else{
                close()
            }
        case "closeLinear":
            self.delegate?.onCloseLinear()
        default:
            break
        }
    }
}
