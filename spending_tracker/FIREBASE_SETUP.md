# Firebase setup — ZenSpend (`zenspend-af9c2`)

This guide lists everything to enable in [Firebase Console](https://console.firebase.google.com/project/zenspend-af9c2) so **Crashlytics**, **app updates**, and **legal documents** work.

---

## 1. Project checklist

| Service | Console path | Required for |
|---------|----------------|--------------|
| **Firebase Core** | Already configured via `flutterfire configure` | App startup |
| **Crashlytics** | Build → Crashlytics | Crash reporting |
| **Remote Config** | Engage → Remote Config | Updates + Privacy/Terms |

---

## 2. Enable Crashlytics

1. Open **Build → Crashlytics**
2. Click **Enable Crashlytics**
3. Run the app once on a **real device** (Crashlytics is limited on web/emulator)
4. Optional: trigger a test crash in debug:
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```

**Android:** `google-services` + Crashlytics Gradle plugins are already in `android/app/build.gradle.kts`.

**iOS:** Run `pod install` in `ios/` after `flutter pub get`.

---

## 3. Enable Remote Config

1. Open **Engage → Remote Config**
2. Click **Create configuration** (if first time)
3. Add every parameter below
4. Click **Publish changes**

### Import template (fastest)

From the project folder:

```bash
cd spending_tracker
dart run tool/generate_remote_config.dart
```

This creates `firebase/remote_config_template.json`. In Firebase Console:

1. Remote Config → **⋮** menu → **Upload template** (or add parameters manually from the table below)
2. Review values → **Publish**

---

## 4. Remote Config parameters

### App updates

| Parameter | Type | Example | Purpose |
|-----------|------|---------|---------|
| `min_version_android` | String | `1.0.0` | **Force** update if installed version is lower (Android) |
| `min_version_ios` | String | `1.0.0` | **Force** update if installed version is lower (iOS) |
| `latest_version` | String | `1.0.0` | Latest store version |
| `force_update` | Boolean | `false` | If `true`, users below `latest_version` must update |
| `update_message` | String | `A new version of ZenSpend is available.` | Shown in update dialog |
| `play_store_url` | String | `https://play.google.com/store/apps/details?id=com.zenspend.app` | Android store link |
| `app_store_url` | String | Your App Store URL | iOS store link |

**Force update:** Set `min_version_android` / `min_version_ios` higher than the installed version (e.g. `2.0.0`), **or** set `force_update` = `true` and `latest_version` above current.

**Optional update:** Set `latest_version` above current with `force_update` = `false`.

### Legal documents (hosted in Firebase)

| Parameter | Type | Example | Purpose |
|-----------|------|---------|---------|
| `privacy_policy` | String | Full text (see bundled default) | In-app Privacy Policy |
| `terms_of_service` | String | Full text (see bundled default) | In-app Terms of Service |
| `privacy_policy_updated` | String | `June 29, 2026` | “Last updated” label |
| `terms_of_service_updated` | String | `June 29, 2026` | “Last updated” label |
| `support_email` | String | `hello@cyfur.in` | Support contact |

**Editing legal text:** Update the string in Remote Config → **Publish**. Users get new text on next app launch (or pull-to-refresh on the legal screen). No app store release required.

**Default copy** is bundled in `lib/core/legal/legal_documents.dart` and used when offline or before fetch completes.

---

## 5. App Store / Play Store URLs

For store submission, use the **same legal text** as in Remote Config:

- Privacy policy URL: `https://cyfur.in/zenspend/privacy` (host a public page mirroring `privacy_policy`)
- Terms URL: `https://cyfur.in/zenspend/terms`

Stores require a **public HTTPS URL** even though the app loads text from Firebase.

---

## 6. Data safety / privacy questionnaire (quick answers)

| Question | Answer |
|----------|--------|
| Collect personal financial transactions? | **No** (stored on device only) |
| Collect crash data? | **Yes** — Firebase Crashlytics, not sold |
| Collect device IDs? | **Yes** — via Firebase for crashes/config |
| Data encrypted in transit? | **Yes** (HTTPS) |
| User can request deletion? | **Yes** — in-app Erase all Data |
| Support email | `hello@cyfur.in` |

---

## 7. Verify everything works

1. **Remote Config:** Settings → About → Privacy Policy / Terms (should show full text; pull to refresh)
2. **Updates:** Set `min_version_android` to `99.0.0` → restart app → force-update dialog
3. **Crashlytics:** Run on device → Crashlytics dashboard within ~15 minutes after a crash
4. **Offline legal:** Enable airplane mode → open Privacy Policy → bundled text still appears

---

## 8. Troubleshooting

| Issue | Fix |
|-------|-----|
| Remote Config not updating | Publish changes in Console; wait 1 min (debug) or 1 hour (release fetch interval) |
| Crashlytics empty | Use physical device; ensure Google Play services (Android) |
| Web build | Firebase works on web but Crashlytics/update checks are best tested on mobile |
| Parameter too long | Legal text must stay under Remote Config size limits (~1 MB per parameter) |

---

**Project ID:** `zenspend-af9c2`  
**Android package:** `com.zenspend.app`  
**iOS bundle:** `com.zenspend.app`
