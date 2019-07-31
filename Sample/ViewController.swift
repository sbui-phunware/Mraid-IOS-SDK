//
//  ViewController.swift
//  MRAID Sample
//
//  Copyright © 2018 Phunware. All rights reserved.
//

import UIKit
import Phunware

class ViewController: UIViewController, PWInterstitialDelegate, PWVASTDelegate {
    

    var banner: PWBanner?
    var interstitial: PWInterstitial?
    var vast:PWVASTVideo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClick(_ sender: Any) {
        let config = PlacementRequestConfig(accountId: 174812, zoneId: 335348, width:320, height:50, customExtras:nil)
        Phunware.requestPlacement(with: config) { response in
            switch response {
            case .success(_ , let placements):
                guard placements.count == 1 else {
                    return
                }
                guard placements[0].isValid else {
                    return
                }
                if(placements[0].body != nil && placements[0].body != ""){
                    self.interstitial = PWInterstitial(placement:placements[0], parentViewController:self, delegate:self, respectSafeAreaLayoutGuide:true)
                }
            default:
                return
            }
        }
    }
    
    @IBAction func displayInterstitial(_ sender: Any){
        self.interstitial?.display()
    }
    
    @IBAction func onClickBanner(_ sender: Any) {
        let config = PlacementRequestConfig(accountId: 174812, zoneId: 335387, width:nil, height:nil, customExtras:nil)
        Phunware.requestPlacement(with: config) { response in
            switch response {
            case .success(_ , let placements):
                guard placements.count == 1 else {
                    // error
                    return
                }
                guard placements[0].isValid else {
                    // error
                    return
                }
                self.banner?.destroy()
                self.banner = PWBanner(placement:placements[0], parentViewController:self, position:Positions.BOTTOM_CENTER)
            case .badRequest(let statusCode, let responseBody):
                return
            case .invalidJson(let responseBody):
                return
            case .requestError(let error):
                return
            }
        }
    }
    
    @IBAction func onClickVAST(_ sender: Any){
        vast = PWVASTVideo()
        vast!.initialize(accountID: 174812, zoneID:6792, publisherID:61936, delegate:self)
        vast!.preload(container: self.view)
    }
    
    
    func interstitialReady(_ interstitial: PWInterstitial) {
        //interstitial.display()
        print("ready")
    }
    
    func interstitialFailedToLoad(_ interstitial: PWInterstitial) {
        print("failed")
    }
    
    func interstitialClosed(_ interstitial: PWInterstitial) {
        print("close")
    }
    
    func interstitialStartLoad(_ interstitial: PWInterstitial) {
        print("start load")
    }
    
    func onMute() {
        print("mute")
    }
    
    func onUnmute() {
        print("unmute")
    }
    
    func onPause() {
        print("pause")
    }
    
    func onResume() {
        print("resume")
    }
    
    func onRewind() {
        print("rewind")
    }
    
    func onSkip() {
        print("skip")
    }
    
    func onPlayerExpand() {
        print("playerExpand")
    }
    
    func onPlayerCollapse() {
        print("playerCollapse")
    }
    
    func onNotUsed() {
        print("notUsed")
    }
    
    func onLoaded() {
        print("loaded")
    }
    
    func onStart() {
        print("start")
    }
    
    func onFirstQuartile() {
        print("firstQuartile")
    }
    
    func onMidpoint() {
        print("midpoint")
    }
    
    func onThirdQuartile() {
        print("thirdQuartile")
    }
    
    func onComplete() {
        print("complete")
    }
    
    func onCloseLinear() {
        print("closeLinear")
    }
    
    func onBrowserOpening(){
        print("onBrowserOpening")
    }
    
    func onBrowserClosing(){
        print("onBrowserClosing")
    }
    
    func onReady(){
        print("onReady")
        print("Autoplaying VAST")
        self.vast!.display()
    }
    
    func onError(){
        print("onError")
    }
    
}

