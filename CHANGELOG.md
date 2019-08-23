
# Version 4.0.1

- **Features**
  - Image banners can be created by passing a containing UIView, and so can be placed anywhere
  - The transition to VAST ads was made smoother
  - VAST ads now behave like Interstitials, where they must be preloaded and displayed when ready
  - Basic image banners can now supports auto refresh.  (Configured in the Zone properties)
  - New VAST events (onBrowserOpened, onBrowserClosed, onReady, onError)
- **Bug Fixes**
  - Fixed a VAST issue where certain click through urls would not load in a browser
  - Fixed a problem with absolute positioned ads not displaying in the correct location
  - Ads should display correctly on devices with non rectangular screen edges (iPhone X, iPhone XR)
