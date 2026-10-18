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
[ "$ONLY_REVIEW" = 1 ] && LANGS=""
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

# 인앱 구입 심사용 스크린샷 — 결제 화면(영어), 상품마다 그 요금제를 고른 모습.
# App Store Connect ▸ 구독/인앱 구입 ▸ 해당 상품 ▸ 심사 정보 ▸ 스크린샷 에 직접 올린다 (DeployBar 는 올리지 않는다).
if [ "${REVIEW:-1}" = 1 ]; then
  mkdir -p "$ROOT/docs/screenshots/review"
  # 설치 직후 첫 실행은 느려 빈 화면이 찍힌다 — 한 번 띄워 데워 둔다.
  xcrun simctl launch "$UDID" $BUNDLE -HantamScene paywall >/dev/null; sleep 8
  for PLAN in monthly yearly lifetime; do
    xcrun simctl terminate "$UDID" $BUNDLE 2>/dev/null || true
    xcrun simctl launch "$UDID" $BUNDLE -AppleLanguages "(en)" -AppleLocale en_US \
      -HantamScene paywall -HantamPlan $PLAN -HantamDemoPhoto "$PHOTO" >/dev/null
    sleep 7
    xcrun simctl io "$UDID" screenshot "$ROOT/docs/screenshots/review/raw-$PLAN.png" >/dev/null 2>&1
    # 1320×2868 → 1242×2688 (이 계정의 iPhone 제출 규격)
    ffmpeg -loglevel error -y -i "$ROOT/docs/screenshots/review/raw-$PLAN.png" \
      -vf "scale=1242:2699,crop=1242:2688:0:0" "$ROOT/docs/screenshots/review/$PLAN.png"
    rm "$ROOT/docs/screenshots/review/raw-$PLAN.png"
    echo "🧾 review/$PLAN"
  done
  xcrun simctl terminate "$UDID" $BUNDLE 2>/dev/null || true
fi
