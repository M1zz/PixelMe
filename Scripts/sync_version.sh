#!/bin/bash
# sync_version.sh - AppConfig.swift에서 버전을 읽어 pbxproj에 자동 반영
# Single source of truth: AppConfig.swift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/PixelMe/AppConfig.swift"
PBXPROJ="$PROJECT_DIR/PixelMe.xcodeproj/project.pbxproj"

# AppConfig.swift에서 버전 추출
APP_VERSION=$(grep 'static let appVersion' "$CONFIG_FILE" | sed 's/.*"\(.*\)".*/\1/')
BUILD_NUMBER=$(grep 'static let buildNumber' "$CONFIG_FILE" | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$APP_VERSION" ] || [ -z "$BUILD_NUMBER" ]; then
    echo "error: AppConfig.swift에서 버전을 읽을 수 없습니다"
    exit 1
fi

# pbxproj 업데이트
sed -i '' "s/MARKETING_VERSION = .*;/MARKETING_VERSION = $APP_VERSION;/g" "$PBXPROJ"
sed -i '' "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" "$PBXPROJ"

echo "✅ Version synced: $APP_VERSION (build $BUILD_NUMBER)"
