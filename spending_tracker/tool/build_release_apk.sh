#!/usr/bin/env bash
set -euo pipefail

# Run from repo root or spending_tracker/
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Cleaning previous build artifacts..."
flutter clean

echo "==> Fetching dependencies..."
flutter pub get

echo "==> Regenerating launcher icons from assets/icon/app_icon.png..."
dart run flutter_launcher_icons

echo "==> Building release APK..."
flutter build apk --release

APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Done: $APK"
echo "Package: com.zenspend.app | Label: MoneySeer"
echo ""
echo "If the device still shows the old name or icon:"
echo "  1. Uninstall any old 'spending_tracker' app (com.example.spending_tracker)."
echo "  2. Uninstall the previous build, then install this APK."
echo "  3. Restart the device or clear your launcher cache if the icon is stuck."
