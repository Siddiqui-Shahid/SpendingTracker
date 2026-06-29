# Release Build Guide — SpendZ

## Android upload key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` → `android/key.properties` and fill in paths/passwords.

Build release:

```bash
cd spending_tracker
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS distribution

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** → **Signing & Capabilities**
3. Team: your Apple Developer team
4. Bundle Identifier: `com.zenspend.app`
5. Enable **Automatically manage signing** for Debug; use Distribution profile for Release
6. Product → Archive → Distribute to App Store Connect

```bash
flutter build ipa --release
```

## Firebase

Already configured via:

```bash
flutterfire configure --project=zenspend-af9c2
```

Enable **Crashlytics** and **Remote Config** in Firebase Console for project `zenspend-af9c2`.

## Version bumps

Update `version` in `pubspec.yaml` (e.g. `1.0.1+2`) before each store upload.

## Host legal pages

Publish `docs/legal/PRIVACY_POLICY.md` and `TERMS_OF_SERVICE.md` to a public URL and update `lib/core/config/app_config.dart` if URLs change.
