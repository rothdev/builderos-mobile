#!/usr/bin/env python3
"""
Build comprehensive BuilderOS Xcode project with curated file list
"""

import uuid
import json
from pathlib import Path

def generate_uuid():
    """Generate a 24-character hex UUID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

# Curated list of files for the complete 4-tab app
FILES_TO_INCLUDE = [
    # Entry Point
    "BuilderOSApp.swift",

    # Models
    "Models/Capsule.swift",
    "Models/SystemStatus.swift",
    "Models/TailscaleDevice.swift",

    # Services - Core
    "Services/BuilderOSAPIClient.swift",
    "Services/TailscaleConnectionManager.swift",

    # Services - SSH
    "BuilderSystemMobile/Services/SSH/SSHConfiguration.swift",
    "BuilderSystemMobile/Services/SSH/SSHService.swift",

    # Services - Voice
    "BuilderSystemMobile/Services/Voice/VoiceManager.swift",
    "BuilderSystemMobile/Services/Voice/TTSManager.swift",

    # Main Views
    "Views/MainContentView.swift",
    "Views/DashboardView.swift",
    "Views/OnboardingView.swift",
    "Views/LocalhostPreviewView.swift",
    "Views/SettingsView.swift",
    "Views/CapsuleDetailView.swift",

    # Chat Feature (Tab 2)
    "BuilderSystemMobile/Features/Chat/Views/ChatView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatHeaderView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatMessagesView.swift",
    "BuilderSystemMobile/Features/Chat/Views/ChatMessageView.swift",
    "BuilderSystemMobile/Features/Chat/Views/QuickActionsView.swift",
    "BuilderSystemMobile/Features/Chat/Views/VoiceInputView.swift",
    "BuilderSystemMobile/Features/Chat/Views/TTSButton.swift",
    "BuilderSystemMobile/Features/Chat/ViewModels/ChatViewModel.swift",
    "BuilderSystemMobile/Features/Chat/Models/ChatMessage.swift",

    # Connection Feature
    "BuilderSystemMobile/Features/Connection/Views/ConnectionDetailsView.swift",

    # Design System
    "Utilities/Colors.swift",
    "Utilities/Typography.swift",
    "Utilities/Spacing.swift",
    "BuilderSystemMobile/Common/Theme.swift",
]

def create_file_info(relative_path):
    """Create file metadata for Xcode"""
    return {
        'name': Path(relative_path).name,
        'path': relative_path,
        'uuid': generate_uuid()
    }

def organize_into_groups(files):
    """Organize files into logical Xcode groups"""
    groups = {}

    for file_info in files:
        path_parts = Path(file_info['path']).parts

        if len(path_parts) == 1:
            # Root level
            if 'Root' not in groups:
                groups['Root'] = {'uuid': generate_uuid(), 'files': []}
            groups['Root']['files'].append(file_info)
        else:
            # Grouped by first directory
            group_name = path_parts[0]
            if group_name not in groups:
                groups[group_name] = {'uuid': generate_uuid(), 'files': []}
            groups[group_name]['files'].append(file_info)

    return groups

def create_pbxproj_content(project_name, files, groups):
    """Generate complete project.pbxproj content"""

    # Main UUIDs
    project_uuid = generate_uuid()
    target_uuid = generate_uuid()
    build_config_debug_uuid = generate_uuid()
    build_config_release_uuid = generate_uuid()
    config_list_uuid = generate_uuid()
    target_config_list_uuid = generate_uuid()
    sources_build_phase_uuid = generate_uuid()
    resources_build_phase_uuid = generate_uuid()
    frameworks_build_phase_uuid = generate_uuid()
    main_group_uuid = generate_uuid()
    products_group_uuid = generate_uuid()
    app_product_uuid = generate_uuid()
    root_group_uuid = generate_uuid()
    target_debug_uuid = generate_uuid()
    target_release_uuid = generate_uuid()

    # Assets
    assets_uuid = generate_uuid()

    # Build PBXBuildFile section
    build_files = []
    for file_info in files:
        build_files.append(
            f"\t\t{file_info['uuid']}1 /* {file_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_info['uuid']} /* {file_info['name']} */; }};"
        )
    build_files.append(
        f"\t\t{assets_uuid}1 /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_uuid} /* Assets.xcassets */; }};"
    )

    # PBXFileReference section
    file_refs = [
        f"\t\t{app_product_uuid} /* {project_name}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {project_name}.app; sourceTree = BUILT_PRODUCTS_DIR; }};",
        f"\t\t{assets_uuid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};"
    ]

    for file_info in files:
        file_refs.append(
            f"\t\t{file_info['uuid']} /* {file_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_info['path']}; sourceTree = \"<group>\"; }};"
        )

    # Build group structure
    main_group_children = []
    for group_name, group_info in groups.items():
        if group_name == 'Root':
            for file_info in group_info['files']:
                main_group_children.append(f"\t\t\t\t{file_info['uuid']} /* {file_info['name']} */,")
        else:
            main_group_children.append(f"\t\t\t\t{group_info['uuid']} /* {group_name} */,")
    main_group_children.append(f"\t\t\t\t{assets_uuid} /* Assets.xcassets */,")

    # PBXGroup section
    groups_section = [
        f"""\t\t{root_group_uuid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{main_group_uuid} /* {project_name} */,
\t\t\t\t{products_group_uuid} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};""",

        f"""\t\t{products_group_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_uuid} /* {project_name}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};""",

        f"""\t\t{main_group_uuid} /* {project_name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(main_group_children)}
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};"""
    ]

    # Add subgroups
    for group_name, group_info in groups.items():
        if group_name != 'Root':
            group_children = [f"\t\t\t\t{f['uuid']} /* {f['name']} */," for f in group_info['files']]
            groups_section.append(
                f"""\t\t{group_info['uuid']} /* {group_name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(group_children)}
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};"""
            )

    # Sources build phase
    source_files_in_build = [f"\t\t\t\t{f['uuid']}1 /* {f['name']} in Sources */," for f in files]

    pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{frameworks_build_phase_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(groups_section)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_uuid} /* {project_name} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_config_list_uuid} /* Build configuration list for PBXNativeTarget "{project_name}" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_build_phase_uuid} /* Sources */,
\t\t\t\t{frameworks_build_phase_uuid} /* Frameworks */,
\t\t\t\t{resources_build_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {project_name};
\t\t\tproductName = {project_name};
\t\t\tproductReference = {app_product_uuid} /* {project_name}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{project_uuid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_uuid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {config_list_uuid} /* Build configuration list for PBXProject "{project_name}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {root_group_uuid};
\t\t\tproductRefGroup = {products_group_uuid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uuid} /* {project_name} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{resources_build_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{assets_uuid}1 /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_build_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(source_files_in_build)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{build_config_debug_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{build_config_release_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{target_debug_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "BuilderOS needs microphone access for voice input in chat.";
\t\t\t\tINFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "BuilderOS uses speech recognition for voice commands.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{target_release_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "BuilderOS needs microphone access for voice input in chat.";
\t\t\t\tINFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "BuilderOS uses speech recognition for voice commands.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{config_list_uuid} /* Build configuration list for PBXProject "{project_name}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{build_config_debug_uuid} /* Debug */,
\t\t\t\t{build_config_release_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "{project_name}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{target_debug_uuid} /* Debug */,
\t\t\t\t{target_release_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uuid} /* Project object */;
}}
"""

    return pbxproj

def create_workspace_files(project_dir):
    """Create workspace and supporting files"""
    workspace_dir = project_dir / "project.xcworkspace"
    workspace_dir.mkdir(exist_ok=True)

    workspace_contents = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    (workspace_dir / "contents.xcworkspacedata").write_text(workspace_contents)

    # Create xcshareddata with workspace checks
    shared_dir = workspace_dir / "xcshareddata"
    shared_dir.mkdir(exist_ok=True)

    import plistlib
    workspace_checks = {'IDEDidComputeMac32BitWarning': True}
    with open(shared_dir / "IDEWorkspaceChecks.plist", 'wb') as f:
        plistlib.dump(workspace_checks, f)

def ensure_assets():
    """Ensure Assets.xcassets exists"""
    assets_dir = Path("Assets.xcassets")
    if assets_dir.exists():
        return

    assets_dir.mkdir(parents=True, exist_ok=True)

    # Create Contents.json
    assets_contents = {"info": {"author": "xcode", "version": 1}}
    (assets_dir / "Contents.json").write_text(json.dumps(assets_contents, indent=2))

    # Create AppIcon.appiconset
    appicon_dir = assets_dir / "AppIcon.appiconset"
    appicon_dir.mkdir(exist_ok=True)
    appicon_contents = {
        "images": [{"idiom": "universal", "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1}
    }
    (appicon_dir / "Contents.json").write_text(json.dumps(appicon_contents, indent=2))

    # Create AccentColor.colorset
    accent_dir = assets_dir / "AccentColor.colorset"
    accent_dir.mkdir(exist_ok=True)
    accent_contents = {
        "colors": [{
            "color": {
                "color-space": "srgb",
                "components": {"alpha": "1.000", "blue": "1.000", "green": "0.478", "red": "0.000"}
            },
            "idiom": "universal"
        }],
        "info": {"author": "xcode", "version": 1}
    }
    (accent_dir / "Contents.json").write_text(json.dumps(accent_contents, indent=2))

    print("✅ Created Assets.xcassets")

def main():
    # Verify all source files exist
    src_path = Path.cwd()
    print(f"🔍 Verifying {len(FILES_TO_INCLUDE)} source files...")

    missing = []
    file_objects = []

    for rel_path in FILES_TO_INCLUDE:
        full_path = src_path / rel_path
        if full_path.exists():
            print(f"   ✅ {rel_path}")
            file_objects.append(create_file_info(rel_path))
        else:
            print(f"   ❌ MISSING: {rel_path}")
            missing.append(rel_path)

    if missing:
        print(f"\n❌ ERROR: {len(missing)} files missing!")
        return 1

    print(f"\n✅ All {len(file_objects)} files verified!")

    # Ensure assets exist
    ensure_assets()

    # Organize into groups
    groups = organize_into_groups(file_objects)
    print(f"\n📁 Organized into {len(groups)} groups:")
    for group_name, group_info in groups.items():
        print(f"   • {group_name}: {len(group_info['files'])} files")

    # Create project directory
    project_name = "BuilderOS"
    project_dir = src_path / f"{project_name}.xcodeproj"
    project_dir.mkdir(exist_ok=True)

    # Generate project.pbxproj
    print(f"\n🔨 Generating project.pbxproj...")
    pbxproj_content = create_pbxproj_content(project_name, file_objects, groups)
    (project_dir / "project.pbxproj").write_text(pbxproj_content)

    # Create workspace files
    print(f"🔨 Creating workspace files...")
    create_workspace_files(project_dir)

    print(f"\n✅ SUCCESS: BuilderOS.xcodeproj created!")
    print(f"📁 Location: {project_dir}")
    print(f"🔗 All {len(file_objects)} source files referenced (NOT copied)")
    print(f"\n🚀 Open in Xcode: open '{project_dir}'")
    print(f"📝 Edit in any editor - changes sync everywhere!")

    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())
