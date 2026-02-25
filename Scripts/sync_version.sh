#!/bin/bash
# sync_version.sh - AppConfig.swift에서 버전을 읽어 Info.plist 빌드 설정에 반영
# Single source of truth: AppConfig.swift

CONFIG_FILE="${SRCROOT}/PixelMe/AppConfig.swift"

# AppConfig.swift에서 버전 추출
APP_VERSION=$(grep 'static let appVersion' "$CONFIG_FILE" | sed 's/.*"\(.*\)".*/\1/')
BUILD_NUMBER=$(grep 'static let buildNumber' "$CONFIG_FILE" | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$APP_VERSION" ] || [ -z "$BUILD_NUMBER" ]; then
    echo "error: AppConfig.swift에서 버전을 읽을 수 없습니다"
    exit 1
fi

# Info.plist가 빌드 출력에 있으면 직접 업데이트
PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
if [ -f "$PLIST" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$PLIST" 2>/dev/null
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PLIST" 2>/dev/null
fi

echo "✅ Version synced: $APP_VERSION (build $BUILD_NUMBER)"
