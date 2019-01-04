//
//  ViewController.swift
//  MRAID Sample
//
//  Copyright © 2018 Phunware. All rights reserved.
//

import UIKit
import Phunware

class ViewController: UIViewController, PWInterstitialDelegate {

    var banner: PWBanner!
    var interstitial: PWInterstitial!
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
        self.interstitial.display()
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
    
    
    func interstitialReady(_ interstitial: PWInterstitial) {
        //interstitial.display()
        print("ready");
    }
    
    func interstitialFailedToLoad(_ interstitial: PWInterstitial) {
        print("failed");
    }
    
    func interstitialClosed(_ interstitial: PWInterstitial) {
        print("close");
    }
    
    func interstitialStartLoad(_ interstitial: PWInterstitial) {
        print("start load");
    }
}

