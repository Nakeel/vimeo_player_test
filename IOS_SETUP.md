# iOS Setup

Required changes before building on iOS.

## 1. NSAppTransportSecurity

Vimeo streams use non-standard domains and require arbitrary network loads.

**File:** `ios/Runner/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

**Status:** Already applied in this repo.

---

## 2. Podfile — iOS Platform Version

`flutter_inappwebview` requires iOS 12+. Setting `14.0` gives headroom for modern WebKit APIs.

**File:** `ios/Podfile`

```ruby
platform :ios, '14.0'
```

**Status:** Already applied in this repo.

---

## 3. Physical Device Required

Vimeo playback does **not** work on the iOS Simulator. The `WKWebView` instance inside `flutter_inappwebview` cannot play protected or HLS streams in the simulator environment.

Always test on a real iPhone or iPad.

---

## 4. Install Pods & Run

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run --debug
```

For release:

```bash
flutter build ipa --release
```

---

## 5. Xcode Minimum Deployment Target

If Xcode shows a deployment target warning, open `ios/Runner.xcworkspace` in Xcode and set the deployment target to **14.0** under **Runner → General → Minimum Deployments**.
