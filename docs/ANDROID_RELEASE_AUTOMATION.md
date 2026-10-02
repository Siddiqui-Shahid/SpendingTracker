# Android release automation

Every push to the protected `master` branch runs
`.github/workflows/android-production-release.yml`.

The workflow:

1. runs the Flutter test suite;
2. generates a monotonically increasing Android version code and patch version;
3. builds a signed Android App Bundle;
4. publishes the bundle to the Google Play production track; and
5. creates a matching GitHub release containing the `.aab` file.

The first workflow run from the current `1.0.2+102` base produces
`1.0.3+100001`. Later runs continue increasing both values.

## Required GitHub environment and secrets

Create a GitHub Actions environment named `google-play-production` and add:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded Android upload keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Upload keystore password |
| `ANDROID_KEY_ALIAS` | Upload key alias (currently `upload`) |
| `ANDROID_KEY_PASSWORD` | Upload key password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Full Google Play service-account JSON key |

The Google service account must have access to `com.zenspend.app` in Play
Console and permission to create production releases.

## Recommended `master` protection

- Require a pull request before merging.
- Require one approval.
- Require conversation resolution.
- Block force pushes and branch deletion.
- Require the `Validate Android` status check after its first pull request run.

Do not store keystores, passwords, or service-account JSON in the repository.
