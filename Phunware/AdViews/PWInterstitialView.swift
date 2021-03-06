//
//  ABInterstitialView.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import UIKit
import WebKit

public class PWInterstitialView: UIViewController, WKUIDelegate, WKNavigationDelegate  {
    private var interstitial:PWInterstitial!
    public var delegate:PWInterstitialDelegate!
    public static let DEFAULT_CLOSE_TIMER:Int = 4
    var webView:WKWebView!
    var imageView:UIImageView!
    var bgView:UIView!
    var isReady:Bool = false
    var displayed:Bool = false
    
    var placement:Placement!
    
    // close button
    var closeButton:UIButton?
    var closeTimer:Int = 0
    let closeFadeTime:CGFloat = 0.155
    let closeFadeRate:CGFloat = 0.01 // seconds before updated
    var countdownTimer:Timer?
    var fadeTimer:Timer?
    var fadeDirection:CGFloat = -1.0
    var fadeAmountPerTick:CGFloat?
    
    enum PWInterstitialError: Error {
        case MISSING_PARENT_VIEWCONTROLLER
    }
    
    public func loadHTMLInterstitial(placement:Placement, interstitial:PWInterstitial, closeTime:Int = 0){
        self.closeTimer = max(abs(closeTime), 0)
        self.placement = placement
        self.interstitial = interstitial
        loadWebView()
        webView.loadHTMLString(self.placement.body!, baseURL:nil)
        self.view.backgroundColor = UIColor.black
    }
    
    override public func viewDidLayoutSubviews() {
        webView.frame = CGRect(x:0,y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
    }
    
    public func loadImageInterstitial(imageURL:String, interstitial:PWInterstitial, closeTime:Int = 0){
        self.closeTimer = max(abs(closeTime), 0)
        self.interstitial = interstitial
        loadImageView()
        getImageAsync(imageURL)
    }
    
    func loadWebView(){
        let sw = UIScreen.main.bounds.width
        let sh = UIScreen.main.bounds.height
        let w = CGFloat(self.placement.width)
        let h = CGFloat(self.placement.height)
        bgView = UIView(frame:CGRect(x:0,y:0, width:sw, height:sh))
        bgView.backgroundColor = UIColor.white
        
        
        let frame = CGRect(
            x: (w < sw) ? ((sw - w) / 2) : 0,
            y: (h < sh) ? ((sh - h) / 2) : 0,
            width: min(w, sw),
            height: min(h, sh)
        )
        
        webView = WKWebView(frame: frame)
        if(w > sw){
            let contentSize:CGSize = CGSize(width:w, height:h)
            let viewSize:CGSize = CGSize(width:sw, height:sh)

            let rw:CGFloat = viewSize.width / contentSize.width
            webView.contentScaleFactor = sw
            webView.scrollView.minimumZoomScale = rw
            webView.scrollView.maximumZoomScale = rw
            webView.scrollView.zoomScale = rw
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bounces = false
        }
        
        webView.scrollView.contentInset = UIEdgeInsets(top: -8.0, left: -8.0, bottom: 8, right: 8)
      
        webView.uiDelegate = self
        webView.navigationDelegate = self
        //webView.dataDetectorTypes = UIDataDetectorTypes.all
        webView.isOpaque = true
        webView.isUserInteractionEnabled = true
    }
    
    func loadImageView(){
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        let frame = CGRect(x:0, y:0, width:w, height:h)
        imageView = UIImageView(frame: frame)
        imageView.isOpaque = true
        imageView.isUserInteractionEnabled = true
    }
    
    func getImageAsync(_ imageURL:String){
        imageView.contentMode = .scaleAspectFit
        downloadImage(url: URL(string: imageURL)!)
    }
   
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
                if(!self.isReady){
                    self.isReady = true
                }
                self.delegate.interstitialReady(self.interstitial)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
   
    
    public func display(_ parentViewController:UIViewController) {
        if(isReady && !displayed) {
            if(webView != nil){
                parentViewController.view.addSubview(bgView!)
                parentViewController.view.addSubview(webView!)
                parentViewController.addChild(self)
                addCloseButton(parentViewController)
                displayed = true
            }
            else if(imageView != nil){
                parentViewController.view.addSubview(imageView!);
                parentViewController.addChild(self)
                addCloseButton(parentViewController)
                displayed = true
            }
        }
    }
    
    private func addCloseButton(_ parentVC:UIViewController) {
        let w = parentVC.view.bounds.width
        let closeW = CGFloat(50)
        let closeH = CGFloat(50)
        let closePaddingX = CGFloat(0)
        let closePaddingY = CGFloat(UIApplication.shared.statusBarFrame.height)
        
        let closeX = w - closeW - closePaddingX
        let closeY = closePaddingY
        
        let buttonRect = CGRect(x:closeX, y:closeY, width:closeW, height:closeH)
        
        closeButton = UIButton(frame:buttonRect)
        closeButton!.layer.cornerRadius = 0
        closeButton!.layer.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8).cgColor
        closeButton!.setTitleColor(UIColor.white, for:UIControl.State.normal)
        if(closeTimer > 0){
            setCloseButtonText(String(closeTimer), size:20.0)
            countdownTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:(#selector(updateTimer)), userInfo: nil, repeats:true)
        }else{
            setCloseButtonText("X", size:24.0)
            closeButton!.addTarget(self, action: #selector(onCloseClicked), for:UIControl.Event.touchUpInside)
        }
    
        parentVC.view.addSubview(closeButton!)
    }
    
    @objc func updateTimer(){
        closeTimer -= 1
        if(closeTimer > 0){
            setCloseButtonText(String(closeTimer))
        }
        else{
            setCloseButtonActive()
        }
    }
    
    func setCloseButtonText(_ text:String, size:CGFloat = 20.0){
        closeButton!.setTitle(text as String, for:UIControl.State.normal)
        closeButton!.titleLabel!.font = UIFont.init(descriptor: UIFontDescriptor(name:"Gill Sans", size:size), size: size)
    }
    
    func setCloseButtonActive(){
        fadeAmountPerTick = closeFadeRate / closeFadeTime
        countdownTimer?.invalidate()
        countdownTimer = nil
        closeButton!.addTarget(self, action: #selector(onCloseClicked), for:UIControl.Event.touchUpInside)
        fadeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(closeFadeRate), target:self, selector:(#selector(updateTimerFade)), userInfo: nil, repeats:true)
    }
    
    @objc func updateTimerFade(){
        closeButton!.titleLabel!.alpha += (fadeAmountPerTick! * fadeDirection)
        if(closeButton!.titleLabel!.alpha < 0){
            fadeDirection = 1.0
            setCloseButtonText("X", size:24.0)
        }
        if(closeButton!.titleLabel!.alpha >= 1){
            fadeTimer!.invalidate()
            fadeTimer = nil;
        }
    }
    
    @objc func onCloseClicked(sender: UIButton!){
        bgView?.removeFromSuperview()
        webView?.uiDelegate = nil
        webView?.navigationDelegate = nil
        webView?.removeFromSuperview()
        webView = nil
        imageView?.removeFromSuperview()
        imageView = nil
        closeButton?.removeFromSuperview()
        self.removeFromParent()
        delegate.interstitialClosed(self.interstitial)
    }
    
    public func webView(_ webView: WKWebView,
     decidePolicyFor navigationAction: WKNavigationAction,
     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         let url = navigationAction.request.url
         if(url != nil && url!.absoluteString != "about:blank"){
             if(url!.absoluteString.range(of:"ssp-r.phunware.com") == nil){
                 if #available(iOS 10.0, *) {
                     UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                 } else {
                     // Fallback on earlier versions
                     UIApplication.shared.openURL(url!)
                 }
                 self.placement?.recordClick()
                 decisionHandler(.cancel)
             }else{
                 decisionHandler(.allow)
             }
         }else{
             decisionHandler(.allow)
         }
     }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate.interstitialStartLoad(self.interstitial)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        isReady = false
        delegate.interstitialFailedToLoad(self.interstitial)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(!isReady){
            isReady = true
        }
        delegate.interstitialReady(self.interstitial)
    }
}
