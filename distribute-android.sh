#!/usr/bin/env bash
# Build a signed release APK and push it to Firebase App Distribution.
# One-time setup already done: firebase project aqi-me-app + Android app registered.
# Testers are managed via the "android-testers" group in the Firebase console.
#
# Usage: ./distribute-android.sh "Optional release notes"
set -euo pipefail
cd "$(dirname "$0")"

APP_ID="1:291005509598:android:896c3509eddc6093b4b74f"   # Firebase Android App ID (not secret)
GROUP="android-testers"
NOTES="${1:-New AQI Me preview build}"

echo "==> Building release APK…"
flutter build apk --release

echo "==> Distributing to Firebase App Distribution (group: $GROUP)…"
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app "$APP_ID" \
  --groups "$GROUP" \
  --release-notes "$NOTES"

echo "==> Done. Testers in '$GROUP' get an email + in-app notification."
