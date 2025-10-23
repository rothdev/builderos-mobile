#!/bin/bash
# Build minimal BuilderOS Xcode project with only terminal chat files

set -e

PROJECT_DIR="/Users/Ty/BuilderOS/capsules/builder-system-mobile/src"
PROJECT_NAME="BuilderOS"

cd "$PROJECT_DIR"

# Clean old project
echo "🗑️  Removing old project..."
rm -rf BuilderOS.xcodeproj

# Create Swift source files list
SOURCE_FILES=(
    "BuilderOSApp.swift"
    "Views/MainContentView.swift"
    "Views/TerminalChatView.swift"
    "Views/DashboardView.swift"
    "Views/LocalhostPreviewView.swift"
    "Views/SettingsView.swift"
    "Views/OnboardingView.swift"
    "Views/CapsuleDetailView.swift"
    "Services/TailscaleConnectionManager.swift"
    "Services/BuilderOSAPIClient.swift"
    "Models/Capsule.swift"
    "Models/SystemStatus.swift"
    "Models/TailscaleDevice.swift"
    "Utilities/Colors.swift"
    "Utilities/Typography.swift"
    "Utilities/Spacing.swift"
)

# Verify all files exist
echo "📋 Verifying source files..."
for file in "${SOURCE_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing: $file"
        exit 1
    fi
    echo "   ✅ $file"
done

# Build xcodebuild command
echo "🔨 Creating Xcode project..."
xcode-select --install 2>/dev/null || true

# Use Python to create proper project
python3 << 'PYTHON_EOF'
import subprocess
import os

os.chdir("/Users/Ty/BuilderOS/capsules/builder-system-mobile/src")

# First try using swiftpm to init a package
subprocess.run(["swift", "package", "init", "--type", "executable", "--name", "BuilderOS"],
               capture_output=True)

# Then generate Xcode project from package
result = subprocess.run(
    ["swift", "package", "generate-xcodeproj"],
    capture_output=True,
    text=True
)

if result.returncode == 0:
    print("✅ Project generated successfully")
    print(result.stdout)
else:
    print("❌ Error:", result.stderr)
    exit(1)
PYTHON_EOF

echo "✅ Project created at: BuilderOS.xcodeproj"
echo "🚀 Opening in Xcode..."
open BuilderOS.xcodeproj
