//
//  ViewController.swift
//  SDKTester
//
//  Created by Will Prevett on 2019-06-05.
//  Copyright © 2019 Will Prevett. All rights reserved.
//

import UIKit
import Phunware

class ViewController: UIViewController , UITextFieldDelegate, PWInterstitialDelegate, PWVASTDelegate {

    @IBOutlet weak var btnGetBanner: UIButton!
    @IBOutlet weak var btnGetInterstitial: UIButton!
    @IBOutlet weak var btnGetVASTVideo: UIButton!
    
    @IBOutlet weak var txtAccountID: UITextField!
    @IBOutlet weak var txtZoneID: UITextField!
    @IBOutlet weak var txtPublisherID: UITextField!
    
    @IBOutlet weak var txtLog: UITextView!
    
    @IBOutlet weak var btnTopLeft: UIButton!
    @IBOutlet weak var btnTopCenter: UIButton!
    @IBOutlet weak var btnTopRight: UIButton!
    @IBOutlet weak var btnCenterLeft: UIButton!
    @IBOutlet weak var btnCenter: UIButton!
    @IBOutlet weak var btnCenterRight: UIButton!
    @IBOutlet weak var btnBottomCenter: UIButton!
    @IBOutlet weak var btnBottomLeft: UIButton!
    @IBOutlet weak var btnBottomRight: UIButton!
    
    @IBOutlet weak var btnDisplayInterstitial: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    
    var accountID:Int!
    var zoneID:Int!
    var publisherID:Int!
    
    var selectedPosition:UIButton? = nil
    let selectedColor = UIColor.init(rgb:0x007AFF)
    let unselectedColor = UIColor.init(rgb:0xEFEFEF)
    
    var interstitialReady:Bool = false
    var sdk:SDKConsumer! = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sdk = SDKConsumer(parentViewController:self)
        let log:(String)->Void={ str in
            self.log(str)
        }
        sdk.setLoggingFunction(log)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtAccountID.delegate = self
        txtZoneID.delegate = self
        txtPublisherID.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.closeTextBoxes(_:))))
        selectPosition(btnBottomCenter)
        sdk.setInterstitialDelegate(self)
        sdk.setVASTDelegate(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func onPositionClicked(_ sender: UIButton) {
        selectPosition(sender)
    }
    
    func selectPosition(_ btn:UIButton){
        selectedPosition?.backgroundColor = unselectedColor
        btn.backgroundColor = selectedColor
        selectedPosition = btn
    }
    
    @objc func closeTextBoxes(_ sender:Any){
        if(txtAccountID.isFirstResponder){
            txtAccountID.resignFirstResponder()
        }
        if(txtZoneID.isFirstResponder){
            txtZoneID.resignFirstResponder()
        }
        if(txtPublisherID.isFirstResponder){
            txtPublisherID.resignFirstResponder()
        }
    }
    
    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
        btnDisplayInterstitial.isHidden = !ready
    }
    
    @IBAction func onGetBannerClick(_ sender: Any) {
        if(!validateInputs(includePublisher:false)){
            return
        }
        sdk.setPosition(getPositionString())
        sdk.getBanner(accountID:self.accountID, zoneID:self.zoneID)
        btnDismiss.isHidden = false
    }
    
    @IBAction func onGetInterstitialClick(_ sender: Any) {
        if(!validateInputs(includePublisher:false)){
            return
        }
        setInterstitialReady(false)
        sdk.getInterstitial(accountID:self.accountID, zoneID:self.zoneID)
    }
    
    @IBAction func onGetVASTVideoClick(_ sender: Any) {
        if(!validateInputs(includePublisher:true)){
            return
        }
        sdk.getVASTVideo(accountID: self.accountID, zoneID: self.zoneID, publisherID: self.publisherID)
    }
    
    @IBAction func onDisplayInterstitialClick(_ sender: Any) {
        setInterstitialReady(false)
        sdk.displayInterstitial()
    }
    @IBAction func onDismissClick(_ sender: Any) {
        sdk.banner?.destroy()
        btnDismiss.isHidden = true
    }
    
    func validateInputs(includePublisher:Bool) -> Bool{
        let accountText = txtAccountID.text
        if(accountText == nil || accountText!.isEmpty){
            log("Invalid account ID")
            return false
        }else{
            let accountID = Int(accountText!) ?? 0
            if(accountID == 0){
                log("Invalid account ID")
                return false
            }else{
                self.accountID = accountID
            }
        }
        
        let zoneText = txtZoneID.text
        if(zoneText == nil || zoneText!.isEmpty){
            log("Invalid zone ID")
            return false
        }else{
            let zoneID = Int(zoneText!) ?? 0
            if(zoneID == 0){
                log("Invalid zone ID")
                return false
            }else{
                self.zoneID = zoneID
            }
        }
        
        if(includePublisher){
            let publisherText = txtPublisherID.text
            if(publisherText == nil || publisherText!.isEmpty){
                log("Invalid publisher ID")
                return false
            }else{
                let publisherID = Int(publisherText!) ?? 0
                if(publisherID == 0){
                    log("Invalid publisher ID")
                    return false
                }else{
                    self.publisherID = publisherID
                }
            }
        }
        
        return true
    }
    
    func getPositionString() -> String {
        switch(selectedPosition){
        case btnTopLeft:
            return Positions.TOP_LEFT
        case btnTopCenter:
            return Positions.TOP_CENTER
        case btnTopRight:
            return Positions.TOP_RIGHT
        case btnCenterLeft:
            return Positions.CENTER_LEFT
        case btnCenter:
            return Positions.CENTER
        case btnCenterRight:
            return Positions.CENTER_RIGHT
        case btnBottomLeft:
            return Positions.BOTTOM_LEFT
        case btnBottomCenter:
            return Positions.BOTTOM_CENTER
        case btnBottomRight:
            return Positions.BOTTOM_RIGHT
        default:
            return Positions.BOTTOM_CENTER
        }
    }
    
    
    // DELEGATE FUNCTIONS
    func log(_ str:String){
        txtLog.text = ("> " + str + "\n" + txtLog.text).trunc(length:32767) // int16.max
    }
    
    func interstitialReady(_ interstitial: PWInterstitial) {
        log("Interstitial :: ready")
        setInterstitialReady(true)
    }
    
    func interstitialFailedToLoad(_ interstitial: PWInterstitial) {
        log("Interstitial :: failed")
    }
    
    func interstitialClosed(_ interstitial: PWInterstitial) {
        log("Interstitial :: close")
    }
    
    func interstitialStartLoad(_ interstitial: PWInterstitial) {
        log("Interstitial :: start load")
    }
    
    func onMute() {
        log("VAST :: mute")
    }
    
    func onUnmute() {
        log("VAST :: unmute")
    }
    
    func onPause() {
        log("VAST :: pause")
    }
    
    func onResume() {
        log("VAST :: resume")
    }
    
    func onRewind() {
        log("VAST :: rewind")
    }
    
    func onSkip() {
        log("VAST :: skip")
    }
    
    func onPlayerExpand() {
        log("VAST :: playerExpand")
    }
    
    func onPlayerCollapse() {
        log("VAST :: playerCollapse")
    }
    
    func onNotUsed() {
        log("VAST :: notUsed")
    }
    
    func onLoaded() {
        log("VAST :: loaded")
    }
    
    func onStart() {
        log("VAST :: start")
    }
    
    func onFirstQuartile() {
        log("VAST :: firstQuartile")
    }
    
    func onMidpoint() {
        log("VAST :: midpoint")
    }
    
    func onThirdQuartile() {
        log("VAST :: thirdQuartile")
    }
    
    func onComplete() {
        log("VAST :: complete")
    }
    
    func onCloseLinear() {
        log("VAST :: closeLinear")
    }
    
}



