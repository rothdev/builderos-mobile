#!/bin/bash

echo "=========================================="
echo "Inject Package Verification Script"
echo "=========================================="
echo ""

PROJECT_DIR="/Users/Ty/BuilderOS/capsules/builderos-mobile/src"
PACKAGE_RESOLVED="$PROJECT_DIR/BuilderOS.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

echo "Checking for Package.resolved file..."

if [ -f "$PACKAGE_RESOLVED" ]; then
    echo "✓ Package.resolved found!"
    echo ""
    echo "Contents:"
    cat "$PACKAGE_RESOLVED"
    echo ""
    
    # Check if Inject is in the resolved file
    if grep -q "Inject" "$PACKAGE_RESOLVED"; then
        echo "✓ Inject package is properly resolved!"
        echo ""
        
        # Try to build the project
        echo "Attempting to build project..."
        cd "$PROJECT_DIR"
        xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS -configuration Debug clean build 2>&1 | grep -E "(BUILD|error|warning|Inject)" | head -30
        
        BUILD_EXIT_CODE=${PIPESTATUS[0]}
        
        if [ $BUILD_EXIT_CODE -eq 0 ]; then
            echo ""
            echo "=========================================="
            echo "✓ SUCCESS! Inject package added and builds!"
            echo "=========================================="
            exit 0
        else
            echo ""
            echo "⚠ Package added but build had issues"
            echo "Check build output above"
            exit 1
        fi
    else
        echo "✗ Package.resolved exists but Inject not found in it"
        exit 1
    fi
else
    echo "✗ Package.resolved not found yet"
    echo ""
    echo "Please complete the manual steps in Xcode:"
    echo "  File → Add Package Dependencies..."
    echo "  URL: https://github.com/krzysztofzablocki/Inject"
    echo ""
    echo "Run this script again after adding the package."
    exit 1
fi
