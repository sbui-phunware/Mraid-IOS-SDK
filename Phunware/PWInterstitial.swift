import Foundation

public class PWInterstitial: NSObject {
    private var mraidInterstitial:PWMRAIDInterstitial?
    private var interstitial:PWInterstitialView?
    private var parentViewController:UIViewController?
    public init(placement:Placement, parentViewController:UIViewController?, delegate:PWInterstitialDelegate, respectSafeAreaLayoutGuide:Bool = false, closeTimer:Int? = nil){
        super.init()
        self.parentViewController = parentViewController
        if(placement.body != nil){
            if(placement.body!.range(of:"mraid.js") != nil){
                mraidInterstitial = PWMRAIDInterstitial()
                mraidInterstitial!.initialize(placement:placement, parentViewController:parentViewController!, interstitial:self)
                mraidInterstitial!.delegate = delegate
                placement.recordImpression()
            }else{
                interstitial = PWInterstitialView()
                interstitial!.delegate = delegate
                interstitial!.loadHTMLInterstitial(placement:placement, interstitial:self, closeTime:(closeTimer != nil) ? closeTimer! : PWInterstitialView.DEFAULT_CLOSE_TIMER)
                placement.recordImpression()
            }
        }else if(placement.imageUrl != nil){
            interstitial = PWInterstitialView()
            interstitial!.delegate = delegate
            interstitial!.loadImageInterstitial(imageURL:placement.imageUrl!, interstitial:self, closeTime:(closeTimer != nil) ? closeTimer! : PWInterstitialView.DEFAULT_CLOSE_TIMER)
            placement.recordImpression()
        }
    }
    
    public func display(_ explicitParent:UIViewController? = nil){
        if(mraidInterstitial != nil){
            mraidInterstitial!.display()
        }else if(interstitial != nil){
            if(explicitParent != nil){
                interstitial!.display(explicitParent!)
            }else if(parentViewController != nil){
                interstitial!.display(parentViewController!)
            }else{
                // error
            }
        }
    }
}
