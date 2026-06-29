# Store Release Checklist — SpendZ

Bundle ID: `com.zenspend.app`  
Firebase project: `zenspend-af9c2`

## Before you submit

### Apple App Store Connect

1. **Create app** with bundle ID `com.zenspend.app`
2. **Privacy Nutrition Labels** — recommended answers:
   - **Data Not Linked to You:** Crash Data (Crashlytics), Product Interaction (optional)
   - **Data Not Collected:** Financial info from transactions (stored only on device — declare as not collected by developer if it never leaves device)
   - **Privacy Policy URL:** use hosted `PRIVACY_POLICY.md` URL (GitHub Pages or your domain)
3. **App Privacy Questionnaire:** Select "No" for data collection where transactions stay on device; declare Crashlytics diagnostics
4. **Export compliance:** Standard encryption (HTTPS/TLS only) — typically exempt
5. **Screenshots:** 6.7" iPhone required; iPad if supporting tablets
6. **Support URL** and **Marketing URL**
7. **Age rating:** 4+ (no restricted content)
8. **Distribution certificate** + **App Store provisioning profile**

### Google Play Console

1. **Create app** with package `com.zenspend.app`
2. **Data safety form:**
   - Financial info: **Not collected** (stored locally only)
   - Crash logs: **Collected**, not shared, for app functionality
   - Data encrypted in transit: Yes (Firebase HTTPS)
   - Users can request deletion: Yes (in-app Erase all Data)
3. **Privacy policy URL** (required)
4. **Upload key** — create with `keytool` and configure `android/key.properties`
5. **Content rating** questionnaire
6. **Target audience** — not designed for children

## Firebase Remote Config (app updates)

In Firebase Console → Remote Config, set:

| Key | Example | Purpose |
|-----|---------|---------|
| `min_version_android` | `1.0.0` | Force update below this version (Android) |
| `min_version_ios` | `1.0.0` | Force update below this version (iOS) |
| `latest_version` | `1.1.0` | Optional update prompt |
| `force_update` | `false` | When `true`, below `latest_version` is forced |
| `update_message` | Custom text | Shown in update dialog |
| `play_store_url` | Play Store link | Android store button |
| `app_store_url` | App Store link | iOS store button (update after approval) |

**Force update:** Set `min_version_*` above the installed version, or set `force_update=true` with a higher `latest_version`.

## Signing

See [RELEASE.md](RELEASE.md) in this folder for Android keystore and iOS certificate steps.

## Manual QA (real devices)

- [ ] Fresh install → onboarding → empty start
- [ ] Onboarding → sample data
- [ ] Add / edit / delete transaction
- [ ] Backup JSON → restore on same or new device
- [ ] Biometric lock enable → kill app → unlock
- [ ] Rotate device (portrait/landscape)
- [ ] 500+ transactions scroll performance
- [ ] Force update dialog (set Remote Config min version high)
- [ ] Optional update dialog
- [ ] About → Privacy / Terms links open
- [ ] VoiceOver (iOS) / TalkBack (Android) on main screens

## Accessibility notes

SpendZ includes Semantics on key widgets (amounts, charts, transaction tiles). Before release, verify:

- All buttons have labels
- Balance is announced correctly
- Sufficient contrast in light and dark mode

## Localization

English (`en`) is configured via `lib/l10n/app_en.arb`. Add `app_hi.arb` (or your market) for Hindi/regional support before regional launch.
