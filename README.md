
phunware-ios-mraid-sdk v0.9 - end user


Requirements:
●	iOS 10.1+
●	Xcode 8.1+
●	Swift 4.1

Installation:

●CocoaPods
To integrate phunware-ios-mraid-sdk into your Xcode project using CocoaPods, 
Update with instructions

●Carthage
To integrate phunware-ios-mraid-sdk into your Xcode project using Carthage,  
Update with instructions

●Manually
Installation of phunware-ios-sdk can be done manually by building and copying the framework into your project.
Usage

●Banners: Banners will be displayed immediately once they are returned from Phunware’s ad server.  

The response functions are included in a closure passed to the placement request.

Creating a banner with PWBanner(placement, parentViewController, position)
-	placement (currently, only one placement should be returned from Phunware, but in the future a list may be returned.  For now, only placement[0] will ever be used.
-	parentViewController (This is the containing controller that should house the banner.  Typically this will be the view controller doing the banner request)
-	position (A string constant noting where the banner should appear on screen.  Positions values can be found in Phunware.MRAIDConstants)

●Retrieving a banner:

Width and height are optional here.  Most of the time the width and height will come from the zone in your Phunware configuration but if that is not set, you may want to set a fallback here.

    let config = PlacementRequestConfig(accountId: 174812, zoneId: 335387, width:320, height:50, customExtras:nil)
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

   

●Interstitials:
Your view controller  will need to implement the PWInterstitialDelegate interface to retrieve event information.

These methods are:

    func interstitialReady(_ interstitial: PWInterstitial) {
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


●Retrieving an interstitial:
  
    let config = PlacementRequestConfig(accountId: 174812, zoneId: 335348, width:nil, height:nil, customExtras:nil)
        Phunware.requestPlacement(with: config) { response in
            switch response {
            case .success(_ , let placements):
                guard placements.count == 1 else {
                    return  // interstitials should currently only return a single ad
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


●Creating an interstitial with 
PWInterstitial(placement, parentViewController, delegate, respectSafeAreaLayoutGuide)
-	placement (as with banners, currently only one placement will be returned from Phunware)
-	parentViewController (The view controller which will contain the interstitial, typically the same controller that retrieves the interstitial placement)
-	delegate (A class that implements the PWInterstitialDelegate interface.  Typically the view controller which retrieves the interstitial)
-	respectSafeAreaLayoutGuide (Some apps may choose to have their layout take into account the safe area layout guide in order to have the status bar showing.  If your app does this, then this setting will tell the interstitial to do the same)

Once retrieved, the interstitialReady function will be called.  After this point you can display the interstitial at any time with:

    interstitial.display();

The interstitial can only been displayed once, after which you must retrieve another one.

●Sample Projects:

Please check out the Swift Sample and ObjC Sample projects inside this repository to see more sample code about how to use this SDK.
License
This SDK is released under the Apache 2.0 license. See LICENSE for more information.
