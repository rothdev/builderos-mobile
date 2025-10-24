#!/usr/bin/env python3
"""
Fix Xcode project by adding missing Swift files to the BuilderOS target.
This script properly updates project.pbxproj with all necessary entries.
"""

import re
import uuid
from pathlib import Path

BASE_DIR = Path("/Users/Ty/BuilderOS/capsules/builderos-mobile/src")
PROJECT_FILE = BASE_DIR / "BuilderOS.xcodeproj" / "project.pbxproj"

# Missing files (file_path, name, group_path)
MISSING_FILES = [
    "Views/RealTerminalView.swift",
    "Views/ProfileSwitcher.swift",
    "Views/QuickActionsBar.swift",
    "Views/CommandSuggestionsView.swift",
    "Views/MultiTabTerminalView.swift",
    "Views/TerminalTabButton.swift",
    "Views/TerminalTabBar.swift",
    "Views/TerminalKeyboardToolbar.swift",
    "Models/TerminalProfile.swift",
    "Models/Command.swift",
    "Models/QuickAction.swift",
    "Models/TerminalTab.swift",
    "Models/TerminalKey.swift",
    "Utilities/TerminalColors.swift",
]

def gen_uuid():
    """Generate Xcode-compatible UUID (24 hex chars uppercase)"""
    return uuid.uuid4().hex[:24].upper()

def main():
    print("🔧 Fixing Xcode project to include all Swift files...")

    # Read project file
    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Generate entries for each missing file
    build_file_entries = []
    file_ref_entries = []
    group_children = []
    sources_phase_entries = []

    for file_path in MISSING_FILES:
        file_name = Path(file_path).name

        # Generate UUIDs
        file_ref_uuid = gen_uuid()
        build_file_uuid = gen_uuid()

        # PBXBuildFile entry
        build_file_entries.append(
            f"\t\t{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};"
        )

        # PBXFileReference entry
        file_ref_entries.append(
            f"\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {file_name}; path = {file_path}; sourceTree = SOURCE_ROOT; }};"
        )

        # PBXGroup child entry
        group_children.append(
            f"\t\t\t\t{file_ref_uuid} /* {file_name} */,"
        )

        # PBXSourcesBuildPhase entry
        sources_phase_entries.append(
            f"\t\t\t\t{build_file_uuid} /* {file_name} in Sources */,"
        )

    # Insert PBXBuildFile entries
    build_section_marker = "/* End PBXBuildFile section */"
    build_section_pos = content.find(build_section_marker)

    if build_section_pos != -1:
        new_entries = "\n".join(build_file_entries) + "\n"
        content = content[:build_section_pos] + new_entries + content[build_section_pos:]
        print(f"✅ Added {len(build_file_entries)} PBXBuildFile entries")

    # Insert PBXFileReference entries
    file_ref_marker = "/* End PBXFileReference section */"
    file_ref_pos = content.find(file_ref_marker)

    if file_ref_pos != -1:
        new_entries = "\n".join(file_ref_entries) + "\n"
        content = content[:file_ref_pos] + new_entries + content[file_ref_pos:]
        print(f"✅ Added {len(file_ref_entries)} PBXFileReference entries")

    # Insert into BuilderOS group children
    # Find the BuilderOS group section
    group_pattern = r'5EE990CFFF044E8491B15FCA /\* BuilderOS \*/ = \{[^}]+children = \([^)]+\);'
    group_match = re.search(group_pattern, content, re.DOTALL)

    if group_match:
        group_section = group_match.group(0)
        # Find the closing parenthesis before the semicolon
        closing_paren_pos = group_section.rfind(");")

        if closing_paren_pos != -1:
            new_children = "\n" + "\n".join(group_children) + "\n\t\t\t"
            updated_group = group_section[:closing_paren_pos] + new_children + group_section[closing_paren_pos:]
            content = content.replace(group_section, updated_group)
            print(f"✅ Added {len(group_children)} files to BuilderOS group")

    # Insert into PBXSourcesBuildPhase
    sources_pattern = r'744C1ACD12414F9299A788C2 /\* Sources \*/ = \{[^}]+files = \([^)]+\);'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if sources_match:
        sources_section = sources_match.group(0)
        # Find the closing parenthesis before the semicolon
        closing_paren_pos = sources_section.rfind(");")

        if closing_paren_pos != -1:
            new_sources = "\n" + "\n".join(sources_phase_entries) + "\n\t\t\t"
            updated_sources = sources_section[:closing_paren_pos] + new_sources + sources_section[closing_paren_pos:]
            content = content.replace(sources_section, updated_sources)
            print(f"✅ Added {len(sources_phase_entries)} files to Sources build phase")

    # Write updated project file
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

    print("\n🎉 Xcode project updated successfully!")
    print("📱 Next steps:")
    print("   1. Open Xcode: open BuilderOS.xcodeproj")
    print("   2. Clean build folder: Cmd+Shift+K")
    print("   3. Build project: Cmd+B")
    print("   4. Test Previews in any view file")

if __name__ == "__main__":
    main()
