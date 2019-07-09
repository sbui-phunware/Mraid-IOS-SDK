//
//  VASTDelegate
//  Phunware
//

//  Copyright © 2019 Phunware, Inc. All rights reserved.
//

import Foundation

public protocol PWVASTDelegate {
    // player operation
    func onMute()
    func onUnmute()
    func onPause()
    func onResume()
    func onRewind()
    func onSkip()
    func onPlayerExpand()
    func onPlayerCollapse()
    func onNotUsed()
    
    // linear
    func onLoaded()
    func onStart()
    func onFirstQuartile()
    func onMidpoint()
    func onThirdQuartile()
    func onComplete()
    //func onOtherAdInteraction() future addition
    func onCloseLinear()
    
    // non linear
    // future additions
    //    func onCreativeView()
    //    func onAcceptInvitation()
    //    func onAdExpand()
    //    func onAdCollapse()
    //    func onMinimize()
    //    func onClose()
    //    func onOverlayViewDuration()
    
    // non standard
    func onBrowserOpening()
    func onBrowserClosing()
}
