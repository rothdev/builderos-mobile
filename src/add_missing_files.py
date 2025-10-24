#!/usr/bin/env python3
"""
Add missing Swift files to BuilderOS Xcode project.
This script updates project.pbxproj to include all Swift files in the BuilderOS target.
"""

import uuid
import re
from pathlib import Path

# Base directory
BASE_DIR = Path("/Users/Ty/BuilderOS/capsules/builderos-mobile/src")
PROJECT_FILE = BASE_DIR / "BuilderOS.xcodeproj" / "project.pbxproj"

# Missing files to add (relative to src/)
MISSING_FILES = [
    ("Views/RealTerminalView.swift", "Views"),
    ("Views/ProfileSwitcher.swift", "Views"),
    ("Views/QuickActionsBar.swift", "Views"),
    ("Views/CommandSuggestionsView.swift", "Views"),
    ("Views/MultiTabTerminalView.swift", "Views"),
    ("Views/TerminalTabButton.swift", "Views"),
    ("Views/TerminalTabBar.swift", "Views"),
    ("Views/TerminalKeyboardToolbar.swift", "Views"),
    ("Models/TerminalProfile.swift", "Models"),
    ("Models/Command.swift", "Models"),
    ("Models/QuickAction.swift", "Models"),
    ("Models/TerminalTab.swift", "Models"),
    ("Models/TerminalKey.swift", "Models"),
    ("Utilities/TerminalColors.swift", "Utilities"),
]

def generate_uuid():
    """Generate Xcode-style UUID (24 hex chars)"""
    return uuid.uuid4().hex[:24].upper()

def read_project_file():
    """Read the project.pbxproj file"""
    with open(PROJECT_FILE, 'r') as f:
        return f.read()

def write_project_file(content):
    """Write the updated project.pbxproj file"""
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

def add_files_to_project(content):
    """Add missing files to project.pbxproj"""

    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}

    for file_path, group in MISSING_FILES:
        file_name = Path(file_path).name
        file_ref_uuid = generate_uuid()
        build_file_uuid = generate_uuid()

        file_refs[file_path] = {
            'uuid': file_ref_uuid,
            'name': file_name,
            'path': file_path,
            'group': group
        }

        build_files[file_path] = {
            'uuid': build_file_uuid,
            'file_ref': file_ref_uuid,
            'name': file_name
        }

    # Add PBXBuildFile entries
    build_file_section = "/* Begin PBXBuildFile section */"
    build_file_index = content.index(build_file_section) + len(build_file_section)

    new_build_files = []
    for file_path, data in build_files.items():
        entry = f"\n\t\t{data['uuid']} /* {data['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {data['file_ref']} /* {data['name']} */; }};"
        new_build_files.append(entry)

    content = content[:build_file_index] + ''.join(new_build_files) + content[build_file_index:]

    # Add PBXFileReference entries
    file_ref_section = "/* Begin PBXFileReference section */"
    file_ref_index = content.index(file_ref_section) + len(file_ref_section)

    new_file_refs = []
    for file_path, data in file_refs.items():
        entry = f"\n\t\t{data['uuid']} /* {data['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {data['name']}; path = {data['path']}; sourceTree = SOURCE_ROOT; }};"
        new_file_refs.append(entry)

    content = content[:file_ref_index] + ''.join(new_file_refs) + content[file_ref_index:]

    # Add files to PBXGroup (BuilderOS group)
    # Find the BuilderOS group
    builderos_group_pattern = r'(5EE990CFFF044E8491B15FCA /\* BuilderOS \*/ = \{[\s\S]*?children = \()([\s\S]*?)(\);)'
    match = re.search(builderos_group_pattern, content)

    if match:
        group_start = match.group(1)
        group_children = match.group(2)
        group_end = match.group(3)

        # Add file references to children
        new_children = []
        for file_path, data in file_refs.items():
            entry = f"\n\t\t\t\t{data['uuid']} /* {data['name']} */,"
            new_children.append(entry)

        new_group = group_start + group_children + ''.join(new_children) + group_end
        content = content[:match.start()] + new_group + content[match.end():]

    # Add to PBXSourcesBuildPhase
    sources_phase_pattern = r'(744C1ACD12414F9299A788C2 /\* Sources \*/ = \{[\s\S]*?files = \()([\s\S]*?)(\);)'
    match = re.search(sources_phase_pattern, content)

    if match:
        phase_start = match.group(1)
        phase_files = match.group(2)
        phase_end = match.group(3)

        # Add build file references
        new_sources = []
        for file_path, data in build_files.items():
            entry = f"\n\t\t\t\t{data['uuid']} /* {data['name']} in Sources */,"
            new_sources.append(entry)

        new_phase = phase_start + phase_files + ''.join(new_sources) + phase_end
        content = content[:match.start()] + new_phase + content[match.end():]

    return content

def main():
    print("🔧 Adding missing Swift files to BuilderOS Xcode project...")
    print(f"📁 Project file: {PROJECT_FILE}")
    print(f"📝 Files to add: {len(MISSING_FILES)}")
    print()

    # Read current project file
    content = read_project_file()
    print("✅ Read project.pbxproj")

    # Add missing files
    updated_content = add_files_to_project(content)
    print("✅ Generated updated project structure")

    # Write updated project file
    write_project_file(updated_content)
    print("✅ Wrote updated project.pbxproj")
    print()
    print("🎉 Complete! All Swift files are now part of the BuilderOS target.")
    print("📱 Open Xcode and verify Previews work for all views.")

if __name__ == "__main__":
    main()
