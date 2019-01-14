# Mraid-IOS-SDK

phunware-ios-sdk v1.02 - end user
Requirements
●	iOS 9.0+
●	Xcode 8.1+
●	Swift 3.0.1+ or Objective-C
Installation
CocoaPods
To integrate phunware-ios-sdk into your Xcode project using CocoaPods, 
Update with instructions
Carthage
To integrate phunware-ios-sdk into your Xcode project using Carthage,  
Update with instructions
Manually
Installation of phunware-ios-sdk can be done manually by building and copying the framework into your project.
Usage
Requesting Single Placement
To request a placement, you can build an instance of PlacementRequestConfig and specify the attributes you want to send:
let config: PlacementRequestConfig
Phunware.requestPlacement(with: config) { response in
  // handle response
}
Requesting Multiple Placements
To request multiple placements, you need an array of PlacementRequestConfigs, and each for a placement respectively:
let configs: [PlacementRequestConfig]
Phunware.requestPlacements(with: configs) { response in
  // handle response
}
Handling the Response
Placement(s) request will accept a completion block that is handed an instance of Response, which is a Swift enum that will indicate success or other status for the request.
Phunware.requestPlacements(with: configs) { response in
  switch response {
  case .success(let responseStatus, let placements): // ...
  case .badRequest(let httpStatusCode, let responseBody): //...
  case .invalidJson(let responseStr): //...
  case .requestError(let error): //..
  }
}
Handle each case as appropriate for your application. In the case of .success you are given a list of Placement that contains each placement requested.
Request Pixel
You can request a pixel simply by giving the URL:
let url: URL
Phunware.requestPixel(with: url)
Record Impression
When you have a Placement, you can record impression by:
let placement: Placement
placement.recordImpression()
The best practice for recording impressions is to do so when the placement is visible on the screen / has been seen by the user.
Record Click
Similarly, you can record click for a Placement:
let placement: Placement
placement.recordClick()
A Note About Objective-C
An additional alternative callback-based method is provided for Objective-C projects. If you're using this SDK from an Objective-C project, you can request placements like this:
PlacementRequestConfig *config = [[PlacementRequestConfig alloc] initWithAccountId:174812 zoneId:335342 width:300 height:250 keywords:@[@"sample2"] click:nil];
[Phunware requestPlacementWithConfig:config success:^(NSString * _Nonnull status, NSArray<Placement *> * _Nonnull placements) {
    // :)
} failure:^(NSNumber * _Nullable statusCode, NSString * _Nullable responseBody, NSError * _Nullable error) {
    // :(
}];
Sample Projects
Please check out the Swift Sample and ObjC Sample projects inside this repository to see more sample code about how to use this SDK.
License
This SDK is released under the Apache 2.0 license. See LICENSE for more information.

