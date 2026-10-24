#!/bin/sh
# 배포 전 게이트 — 여기서 실패하면 DeployBar 가 아카이브를 만들지 않는다.
#
# 사용법:
#   sh scripts/predeploy.sh
#
# 다국어(.xcstrings) 검사는 DeployBar 에 내장돼 있으므로 여기서 다시 하지 않는다.
# 이 스크립트는 "이 앱만의" 검사 — 테스트, 금지 패턴 검사 등 — 를 담는다.
#
# ⚠️ CODE_SIGNING_ALLOWED=NO 로 테스트를 빠르게 만들지 말 것.
#    entitlements 가 빠지면 CloudKit 등 실제 배포 경로에서만 터지는 문제를 놓친다.
set -e
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

SCHEME="Hantam"
PROJECT_FLAG="-project"
PROJECT="Hantam.xcodeproj"

# 도안 엔진 · PDF · 통계 이름 단위 테스트 (HantamTests/PatternEngineTests.swift)
echo "🧪 단위 테스트 ($SCHEME)"
# 이미 켜진 아이폰을 먼저 쓴다 — 막 켜지는 기기에서는 테스트 실행기가 앱을 못 띄울 때가 있다.
# SIM_UDID 를 주면 그 기기를 쓴다(맥을 여럿이 같이 쓸 때 남의 시뮬레이터를 건드리지 않도록).
DEST_ID="${SIM_UDID:-}"
[ -n "$DEST_ID" ] || DEST_ID=$(xcrun simctl list devices booted | grep -E "iPhone" | grep -oE "[0-9A-F-]{36}" | head -1)
[ -n "$DEST_ID" ] || DEST_ID=$(xcrun simctl list devices available | grep -E "iPhone" | grep -oE "[0-9A-F-]{36}" | head -1)
xcodebuild test \
  "$PROJECT_FLAG" "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$DEST_ID" \
  -quiet

echo "🔨 Release 빌드 확인 ($SCHEME)"
xcodebuild build \
  "$PROJECT_FLAG" "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS Simulator" \
  -quiet

echo ""
echo "✅ 게이트 통과 — 배포 가능"
