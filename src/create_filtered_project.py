#!/usr/bin/env python3
"""
Create Xcode project with ONLY specified files (no auto-discovery).
Excludes problematic Chat feature files.
"""
import os
import sys
import uuid
from pathlib import Path

# Files to include
INCLUDE_FILES = [
    "BuilderOSApp.swift",
    "Views/MainContentView.swift",
    "Views/TerminalChatView.swift",
    "Views/DashboardView.swift",
    "Views/LocalhostPreviewView.swift",
    "Views/SettingsView.swift",
    "Views/OnboardingView.swift",
    "Views/CapsuleDetailView.swift",
    "Services/TailscaleConnectionManager.swift",
    "Services/BuilderOSAPIClient.swift",
    "Models/Capsule.swift",
    "Models/SystemStatus.swift",
    "Models/TailscaleDevice.swift",
    "Utilities/Colors.swift",
    "Utilities/Typography.swift",
    "Utilities/Spacing.swift",
]

PROJECT_DIR = Path("/Users/Ty/BuilderOS/capsules/builder-system-mobile/src")
PROJECT_NAME = "BuilderOS"

def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

def main():
    os.chdir(PROJECT_DIR)

    # Remove old project
    project_path = Path(f"{PROJECT_NAME}.xcodeproj")
    if project_path.exists():
        print(f"🗑️  Removing {project_path}")
        os.system(f"rm -rf {project_path}")

    # Verify all files exist
    print("📋 Verifying files...")
    for filepath in INCLUDE_FILES:
        if not Path(filepath).exists():
            print(f"❌ Missing: {filepath}")
            return 1
        print(f"   ✅ {filepath}")

    # Create file metadata
    files = []
    for filepath in INCLUDE_FILES:
        files.append({
            'path': filepath,
            'name': Path(filepath).name,
            'uuid': gen_uuid(),
            'build_uuid': gen_uuid()
        })

    # UUIDs for project structure
    uuids = {
        'project': gen_uuid(),
        'target': gen_uuid(),
        'main_group': gen_uuid(),
        'root_group': gen_uuid(),
        'products_group': gen_uuid(),
        'app_product': gen_uuid(),
        'sources_phase': gen_uuid(),
        'frameworks_phase': gen_uuid(),
        'resources_phase': gen_uuid(),
        'debug_config': gen_uuid(),
        'release_config': gen_uuid(),
        'project_config_list': gen_uuid(),
        'target_config_list': gen_uuid(),
        'target_debug': gen_uuid(),
        'target_release': gen_uuid(),
        'assets': gen_uuid(),
        'assets_build': gen_uuid(),
    }

    # Build PBXBuildFile section
    build_files = []
    for f in files:
        build_files.append(
            f"\t\t{f['build_uuid']} /* {f['name']} in Sources */ = "
            f"{{isa = PBXBuildFile; fileRef = {f['uuid']} /* {f['name']} */; }};"
        )
    build_files.append(
        f"\t\t{uuids['assets_build']} /* Assets.xcassets in Resources */ = "
        f"{{isa = PBXBuildFile; fileRef = {uuids['assets']} /* Assets.xcassets */; }};"
    )

    # Build PBXFileReference section
    file_refs = []
    file_refs.append(
        f"\t\t{uuids['app_product']} /* {PROJECT_NAME}.app */ = "
        f"{{isa = PBXFileReference; explicitFileType = wrapper.application; "
        f"includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )
    for f in files:
        file_refs.append(
            f"\t\t{f['uuid']} /* {f['name']} */ = "
            f"{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; "
            f"name = \"{f['name']}\"; path = \"{f['path']}\"; sourceTree = SOURCE_ROOT; }};"
        )
    file_refs.append(
        f"\t\t{uuids['assets']} /* Assets.xcassets */ = "
        f"{{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; "
        f"path = Assets.xcassets; sourceTree = SOURCE_ROOT; }};"
    )

    # Main group children
    main_children = [f"\t\t\t\t{f['uuid']} /* {f['name']} */," for f in files]
    main_children.append(f"\t\t\t\t{uuids['assets']} /* Assets.xcassets */,")

    # Sources build phase
    source_refs = [f"\t\t\t\t{f['build_uuid']} /* {f['name']} in Sources */," for f in files]

    # Resources build phase
    resource_refs = [f"\t\t\t\t{uuids['assets_build']} /* Assets.xcassets in Resources */,"]

    # Build project.pbxproj
    pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{uuids['frameworks_phase']} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{uuids['root_group']} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{uuids['main_group']} /* {PROJECT_NAME} */,
\t\t\t\t{uuids['products_group']} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{uuids['products_group']} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{uuids['app_product']} /* {PROJECT_NAME}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{uuids['main_group']} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(main_children)}
\t\t\t);
\t\t\tpath = {PROJECT_NAME};
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{uuids['target']} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {uuids['target_config_list']} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{uuids['sources_phase']} /* Sources */,
\t\t\t\t{uuids['frameworks_phase']} /* Frameworks */,
\t\t\t\t{uuids['resources_phase']} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {PROJECT_NAME};
\t\t\tproductName = {PROJECT_NAME};
\t\t\tproductReference = {uuids['app_product']} /* {PROJECT_NAME}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{uuids['project']} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t}};
\t\t\tbuildConfigurationList = {uuids['project_config_list']} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t);
\t\t\tmainGroup = {uuids['root_group']};
\t\t\tproductRefGroup = {uuids['products_group']} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{uuids['target']} /* {PROJECT_NAME} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{uuids['resources_phase']} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(resource_refs)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{uuids['sources_phase']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(source_refs)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{uuids['debug_config']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{uuids['release_config']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = YES;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{uuids['target_debug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{uuids['target_release']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{uuids['project_config_list']} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{uuids['debug_config']} /* Debug */,
\t\t\t\t{uuids['release_config']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{uuids['target_config_list']} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{uuids['target_debug']} /* Debug */,
\t\t\t\t{uuids['target_release']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {uuids['project']} /* Project object */;
}}
"""

    # Write project file
    project_path.mkdir(exist_ok=True)
    (project_path / "project.pbxproj").write_text(pbxproj)

    # Create workspace
    workspace_dir = project_path / "project.xcworkspace"
    workspace_dir.mkdir(exist_ok=True)
    (workspace_dir / "contents.xcworkspacedata").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Workspace version = "1.0">\n'
        '   <FileRef location = "self:">\n'
        '   </FileRef>\n'
        '</Workspace>\n'
    )

    print(f"\n✅ Project created: {project_path}")
    print(f"🚀 Opening in Xcode...")
    os.system(f"open {project_path}")

    return 0

if __name__ == "__main__":
    sys.exit(main())
