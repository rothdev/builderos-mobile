#!/bin/bash
#
# deploy_to_iphone.sh - Build and deploy BuilderOS to iPhone
#
# Usage: ./deploy_to_iphone.sh [iPhone_UDID]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}🏗️  BuilderOS Mobile - Deploy to iPhone${NC}"
echo ""

# Get iPhone UDID (either from argument or detect automatically)
if [ -n "$1" ]; then
    IPHONE_UDID="$1"
else
    echo -e "${YELLOW}Detecting connected iPhone...${NC}"
    IPHONE_UDID=$(xcrun xctrace list devices 2>&1 | grep -m 1 "iPhone" | grep -oE "\([A-F0-9-]{36}\)" | tr -d "()")

    if [ -z "$IPHONE_UDID" ]; then
        echo -e "${RED}❌ No iPhone detected. Connect iPhone and try again.${NC}"
        echo -e "${YELLOW}Or specify UDID: ./deploy_to_iphone.sh YOUR_UDID${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Found iPhone: $IPHONE_UDID${NC}"
fi

# Project paths
PROJECT_DIR="/Users/Ty/BuilderOS/capsules/builderos-mobile"
XCODE_PROJECT="$PROJECT_DIR/src/BuilderOS.xcodeproj"
SCHEME="BuilderOS"
DERIVED_DATA="$PROJECT_DIR/build"

echo ""
echo -e "${CYAN}📦 Building iOS app...${NC}"

# Build for device
xcodebuild -project "$XCODE_PROJECT" \
    -scheme "$SCHEME" \
    -destination "id=$IPHONE_UDID" \
    -derivedDataPath "$DERIVED_DATA" \
    -allowProvisioningUpdates \
    clean build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Find app bundle
APP_BUNDLE=$(find "$DERIVED_DATA/Build/Products/Debug-iphoneos" -name "BuilderOS.app" -print -quit)

if [ -z "$APP_BUNDLE" ]; then
    echo -e "${RED}❌ Could not find BuilderOS.app${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}📲 Installing on iPhone...${NC}"

# Install app
xcrun devicectl device install app --device "$IPHONE_UDID" "$APP_BUNDLE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Deployment complete!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Launch BuilderOS app on iPhone"
    echo "2. Ensure Cloudflare tunnel is running on Mac"
    echo "3. Check connection status in app"
    echo ""
    echo -e "${YELLOW}For hot reload (2-second updates):${NC}"
    echo "1. Open Xcode: open $XCODE_PROJECT"
    echo "2. Run app once (Cmd+R)"
    echo "3. Edit Swift files → Save → See changes in ~2s"
else
    echo -e "${RED}❌ Installation failed${NC}"
    exit 1
fi
