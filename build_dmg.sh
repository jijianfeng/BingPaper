#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="BingPaper"
VERSION="1.0.0"
BUILD_DIR="$PROJECT_DIR/build"
DMG_NAME="$APP_NAME-v$VERSION.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"
DMG_STAGING="$BUILD_DIR/dmg_staging"

# 1. 编译 App
"$PROJECT_DIR/build_app.sh"

# 2. 准备 DMG 打包临时目录
echo "💿 正在打包 $DMG_NAME..."
rm -rf "$DMG_STAGING" "$DMG_PATH"
mkdir -p "$DMG_STAGING"

cp -R "$BUILD_DIR/$APP_NAME.app" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

# 3. 创建 DMG 镜像
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"
rm -rf "$DMG_STAGING"

echo "🎉 DMG 安装包生成完成！"
echo "👉 文件路径: $DMG_PATH"
