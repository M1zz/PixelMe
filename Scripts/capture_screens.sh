#!/bin/sh
# 스토어 스크린샷 원본 찍기 — DEBUG 빌드의 -HantamScene 장면을 언어마다 띄워 찍는다.
#
# 사용법: sh Scripts/capture_screens.sh <앱 경로(.app)> [언어 ...]
#   기기: iPhone 18 Pro Max (1320×2868), 밝은 화면, 상태 막대 9:41
#   결과: docs/screenshots/raw/<언어>/<장면>.png
#   데모 사진: docs/screenshots/raw/assets/demo-beagle.jpg (Unsplash 라이선스 — 상업적 사용 가능)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$1"; shift
LANGS="${*:-ko en ja}"
UDID="${UDID:-7F517AA6-6217-4326-9F6B-5AE490B38C7D}"
BUNDLE=com.leeo.PixelMe
PHOTO="$ROOT/docs/screenshots/raw/assets/demo-beagle.jpg"
SCENES="home maker detail symbols stitch pdf"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light
xcrun simctl status_bar "$UDID" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
xcrun simctl install "$UDID" "$APP"

for L in $LANGS; do
  case $L in ko) LOC=ko_KR;; ja) LOC=ja_JP;; *) LOC=en_US;; esac
  mkdir -p "$ROOT/docs/screenshots/raw/$L"
  for SC in $SCENES; do
    xcrun simctl terminate "$UDID" $BUNDLE 2>/dev/null || true
    xcrun simctl launch "$UDID" $BUNDLE -AppleLanguages "($L)" -AppleLocale $LOC \
      -HantamScene $SC -HantamDemoPhoto "$PHOTO" >/dev/null
    if [ "$SC" = pdf ]; then sleep 11; else sleep 7; fi
    xcrun simctl io "$UDID" screenshot "$ROOT/docs/screenshots/raw/$L/$SC.png" >/dev/null 2>&1
    echo "📸 $L/$SC"
  done
done
xcrun simctl terminate "$UDID" $BUNDLE 2>/dev/null || true
