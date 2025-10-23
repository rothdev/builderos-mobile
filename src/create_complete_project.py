#!/usr/bin/env python3
"""
Create complete BuilderOS Xcode project with ALL implementation files
"""

import subprocess
import sys
from pathlib import Path

# Core implementation files to include (relative to src/)
CORE_FILES = [
    # Entry Point
    "BuilderOSApp.swift",

    # Models
    "Models/Capsule.swift",
    "Models/SystemStatus.swift",
    "Models/TailscaleDevice.swift",

    # Services
    "Services/BuilderOSAPIClient.swift",
    "Services/TailscaleConnectionManager.swift",

    # Views
    "Views/MainContentView.swift",
    "Views/DashboardView.swift",
    "Views/OnboardingView.swift",
    "Views/LocalhostPreviewView.swift",
    "Views/SettingsView.swift",
    "Views/CapsuleDetailView.swift",

    # Chat Feature
    "BuilderSystemMobile/Features/Chat/Views/ChatView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatHeaderView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatMessagesView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatMessageView.swift",
    "BuilderSystemMobile/Features/Chat/Views/QuickActionsView.swift",
    "BuilderSystemMobile/Features/Chat/Views/VoiceInputView.swift",
    "BuilderSystemMobile/Features/Chat/Views/TTSButton.swift",
    "BuilderSystemMobile/Features/Chat/ViewModels/ChatViewModel.swift",
    "BuilderSystemMobile/Features/Chat/Models/ChatMessage.swift",

    # Design System
    "Utilities/Colors.swift",
    "Utilities/Typography.swift",
    "Utilities/Spacing.swift",
]

def main():
    src_path = Path(__file__).parent

    # Verify all files exist
    print("🔍 Verifying files exist...")
    missing = []
    for file_path in CORE_FILES:
        full_path = src_path / file_path
        if full_path.exists():
            print(f"   ✅ {file_path}")
        else:
            print(f"   ❌ MISSING: {file_path}")
            missing.append(file_path)

    if missing:
        print(f"\n❌ ERROR: {len(missing)} files are missing!")
        return 1

    print(f"\n✅ All {len(CORE_FILES)} files verified!")
    print(f"\n🔨 Creating Xcode project with create_linked_xcode_project.py...")

    # The script will auto-discover all Swift files in src/
    # So we just need to call it
    result = subprocess.run([
        "python3",
        "/Users/Ty/BuilderOS/tools/create_linked_xcode_project.py",
        str(src_path.parent),  # capsule path
        "BuilderOS",
        "--xcode-dir",
        str(src_path)
    ])

    return result.returncode

if __name__ == "__main__":
    sys.exit(main())
