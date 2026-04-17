# Android Setup

Required changes before building on Android.

## 1. MainActivity — FlutterFragmentActivity

`vimeo_video_player` uses `flutter_inappwebview` internally, which requires `FlutterFragmentActivity` instead of the default `FlutterActivity`.

**File:** `android/app/src/main/kotlin/ng/groove/udux_concerts_test/MainActivity.kt`

```kotlin
// Before
import io.flutter.embedding.android.FlutterActivity
class MainActivity : FlutterActivity()

// After
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity : FlutterFragmentActivity()
```

**Status:** Already applied in this repo.

---

## 2. Minimum SDK Version

`flutter_inappwebview` requires `minSdkVersion >= 19`, but the player package recommends `24` for reliable Vimeo HLS support.

**File:** `android/app/build.gradle.kts`

```kotlin
// Before
minSdk = flutter.minSdkVersion

// After
minSdk = 24
```

**Status:** Already applied in this repo.

---

## 3. Internet Permission

**File:** `android/app/src/main/AndroidManifest.xml`

Ensure this line is present inside `<manifest>` (Flutter includes it by default):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 4. Build & Run

```bash
flutter pub get
flutter run --debug
```

For release:

```bash
flutter build apk --release
# or
flutter build appbundle --release
```
