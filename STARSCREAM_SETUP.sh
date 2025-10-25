#!/bin/bash
# Starscream Setup Script
# Adds Starscream package dependency to Xcode project

echo "📦 Adding Starscream to Xcode project..."
echo ""
echo "Manual steps required (Xcode GUI):"
echo "1. Open src/BuilderOS.xcodeproj in Xcode"
echo "2. Select the BuilderOS project in navigator"
echo "3. Select the BuilderOS target"
echo "4. Go to 'Package Dependencies' tab"
echo "5. Click '+' button"
echo "6. Enter: https://github.com/daltoniam/Starscream"
echo "7. Version: 4.0.8 (Up to Next Major)"
echo "8. Click 'Add Package'"
echo "9. Select 'BuilderOS' target"
echo "10. Click 'Add Package'"
echo ""
echo "✅ After adding package, run: cd /Users/Ty/BuilderOS/capsules/builderos-mobile && xcodebuild -project src/BuilderOS.xcodeproj -scheme BuilderOS -destination 'generic/platform=iOS Simulator' build"
