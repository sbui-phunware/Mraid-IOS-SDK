//
//  MRAIDInterstitialDelegate.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

public protocol MRAIDInterstitialDelegate {
    // called when the interstitial content is finished loading
    func interstitialReady(_ interstitial:PWMRAIDInterstitial)
    
    // called when an error occurs loading the interstitial content
    func interstitialFailedToLoad(_ interstitial:PWMRAIDInterstitial)
    
    // called when the interstitial has close, and disposed of it's views
    func interstitialClosed(_ interstitial:PWMRAIDInterstitial)
    
    // called when the HTML request starts to load
    func interstitialStartLoad(_ interstitial:PWMRAIDInterstitial)
}
