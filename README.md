# Mobile Apps for Dosenet!

## Author(s)
- Navrit Bal [@navrit](https://github.com/navrit)
- Joseph Curtis [@jccurtis](https://github.com/jccurtis)

## iOS

### Pre-development steps
Install `cocoapods`:
```bash
sudo gem install cocoapods
```
Install `pods` for iOS release:
```bash
cd dosenet-apps/iOS/DoseNet
pod install
```
Sample output:
```
Creating shallow clone of spec repo `master` from `https://github.com/CocoaPods/Specs.git`

CocoaPods 1.0.0.beta.6 is available.
To update use: `gem install cocoapods --pre`
[!] This is a test version we'd love you to try.

For more information see http://blog.cocoapods.org
and the CHANGELOG for this version http://git.io/BaH8pQ.

Updating local specs repositories

CocoaPods 1.0.0.beta.6 is available.
To update use: `gem install cocoapods --pre`
[!] This is a test version we'd love you to try.

For more information see http://blog.cocoapods.org
and the CHANGELOG for this version http://git.io/BaH8pQ.

Analyzing dependencies
Downloading dependencies
Using Alamofire (3.1.4)
Using CSwiftV (0.0.3)
Using Charts (2.1.6)
Using JLToast (1.3.4)
Using SwiftSpinner (0.8.0)
Generating Pods project
Integrating client project
Sending stats
Pod installation complete! There are 5 dependencies from the Podfile and 5 total pods installed.

[!] The `DoseNet [Debug]` target overrides the `EMBEDDED_CONTENT_CONTAINS_SWIFT` build setting defined in `Pods/Target Support Files/Pods-DoseNet/Pods-DoseNet.debug.xcconfig'. This can lead to problems with the CocoaPods installation
    - Use the `$(inherited)` flag, or
    - Remove the build settings from the target.

[!] The `DoseNet [Release]` target overrides the `EMBEDDED_CONTENT_CONTAINS_SWIFT` build setting defined in `Pods/Target Support Files/Pods-DoseNet/Pods-DoseNet.release.xcconfig'. This can lead to problems with the CocoaPods installation
    - Use the `$(inherited)` flag, or
    - Remove the build settings from the target.
```

## Android SDK

Some notes from installing on OSX:

- Bug: `Unable to obtain debug bridge`
- Install `Android SDK Platform Tools` and `Android Support Library` from the SDK manager (`Tools>Android>SDK Manager`)
