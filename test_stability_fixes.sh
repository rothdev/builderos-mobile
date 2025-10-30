#!/bin/bash
# BuilderOS Mobile - Stability Fixes Testing Script
# Run this after deploying to physical device

set -e

DEVICE_UDID="DAA927D8-1126-5084-B72B-5AEE5E90CBB2"
DEVICE_NAME="Roth iPhone"
PROJECT_DIR="/Users/Ty/BuilderOS/capsules/builderos-mobile/src"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BuilderOS Mobile - Stability Testing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Step 1: Build for device
echo "📦 Building for $DEVICE_NAME..."
cd "$PROJECT_DIR"
xcodebuild -project BuilderOS.xcodeproj \
  -scheme BuilderOS \
  -destination "platform=iOS,id=$DEVICE_UDID" \
  -configuration Release \
  -allowProvisioningUpdates \
  build

if [ $? -eq 0 ]; then
  echo "✅ Build succeeded"
else
  echo "❌ Build failed"
  exit 1
fi

# Step 2: Find the app bundle
APP_PATH=$(find build/Release-iphoneos -name "BuilderOS.app" | head -1)
if [ -z "$APP_PATH" ]; then
  echo "❌ Could not find BuilderOS.app"
  exit 1
fi

echo "📱 App bundle: $APP_PATH"

# Step 3: Install to device
echo "📲 Installing to device..."
xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH"

if [ $? -eq 0 ]; then
  echo "✅ Installation succeeded"
else
  echo "❌ Installation failed"
  exit 1
fi

# Step 4: Launch the app
echo "🚀 Launching BuilderOS..."
BUNDLE_ID="com.builderos.ios"
xcrun devicectl device process launch --device "$DEVICE_UDID" "$BUNDLE_ID"

echo
echo "✅ App deployed and launched!"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Manual Testing Checklist:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "1. FREEZING TEST:"
echo "   - Open Claude chat"
echo "   - Send message: 'Write a 5000-word essay'"
echo "   - ✓ Verify UI stays responsive during streaming"
echo "   - ✓ Verify you can scroll while receiving"
echo
echo "2. MEMORY TEST:"
echo "   - Send 50+ short messages rapidly"
echo "   - ✓ Check Settings > General > iPhone Storage"
echo "   - ✓ Memory should stay under 200MB"
echo
echo "3. CONNECTION TEST:"
echo "   - Background the app for 30 seconds"
echo "   - Return to app"
echo "   - ✓ Verify chat still connected"
echo "   - ✓ Send message works immediately"
echo
echo "4. CRASH TEST:"
echo "   - Open/close 10 chat tabs"
echo "   - Switch tabs rapidly 20 times"
echo "   - ✓ App should NOT crash"
echo "   - ✓ All tabs should work"
echo
echo "5. NOTIFICATION TEST (if backend updated):"
echo "   - Close the app completely"
echo "   - Have someone send you a message"
echo "   - ✓ Notification should appear"
echo "   - ✓ Tap opens to chat"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Optional: Start log monitoring
echo "Start monitoring device logs? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "📋 Streaming device logs (Ctrl+C to stop)..."
  xcrun devicectl device log stream --device "$DEVICE_UDID" | grep -E "(BuilderOS|error|warning|crash)"
fi
