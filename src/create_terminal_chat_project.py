#!/usr/bin/env python3
"""
Create BuilderOS Xcode project with only terminal chat files (excluding complex Chat feature).
"""
import os
import uuid
import sys

PROJECT_DIR = "/Users/Ty/BuilderOS/capsules/builder-system-mobile/src"
PROJECT_NAME = "BuilderOS"

# Files to include (relative to PROJECT_DIR)
INCLUDE_FILES = [
    # App entry point
    "BuilderOSApp.swift",

    # Views
    "Views/MainContentView.swift",
    "Views/TerminalChatView.swift",
    "Views/DashboardView.swift",
    "Views/LocalhostPreviewView.swift",
    "Views/SettingsView.swift",
    "Views/OnboardingView.swift",
    "Views/CapsuleDetailView.swift",

    # Services
    "Services/TailscaleConnectionManager.swift",
    "Services/BuilderOSAPIClient.swift",

    # Models
    "Models/Capsule.swift",
    "Models/SystemStatus.swift",
    "Models/TailscaleDevice.swift",

    # Utilities
    "Utilities/Colors.swift",
    "Utilities/Typography.swift",
    "Utilities/Spacing.swift",

    # Assets
    "Assets.xcassets",
    "Info.plist",
    "BuilderOS.entitlements",
]

def generate_uuid():
    """Generate uppercase UUID for Xcode."""
    return str(uuid.uuid4()).upper().replace('-', '')[:24]

def get_file_type(filename):
    """Determine Xcode file type."""
    ext = os.path.splitext(filename)[1]
    if ext == '.swift':
        return 'sourcecode.swift'
    elif ext == '.plist':
        return 'text.plist.xml'
    elif ext == '.entitlements':
        return 'text.plist.entitlements'
    elif filename.endswith('.xcassets'):
        return 'folder.assetcatalog'
    return 'text'

def get_build_phase(filename):
    """Determine which build phase this file belongs to."""
    ext = os.path.splitext(filename)[1]
    if ext == '.swift':
        return 'sources'
    elif filename.endswith('.xcassets') or ext == '.plist' or ext == '.entitlements':
        return 'resources'
    return None

def create_pbx_project():
    """Generate PBXProject content."""

    # Generate UUIDs for all files and groups
    file_refs = {}
    build_files = {}

    # Main group UUID
    main_group_uuid = generate_uuid()

    # Create file references
    file_ref_section = []
    build_file_section = []
    source_build_phase_files = []
    resource_build_phase_files = []

    for filepath in INCLUDE_FILES:
        full_path = os.path.join(PROJECT_DIR, filepath)
        if not os.path.exists(full_path):
            print(f"⚠️  Warning: {filepath} not found, skipping")
            continue

        file_uuid = generate_uuid()
        build_file_uuid = generate_uuid()

        file_refs[filepath] = file_uuid
        build_files[filepath] = build_file_uuid

        file_type = get_file_type(filepath)
        filename = os.path.basename(filepath)

        # PBXFileReference
        file_ref_section.append(
            f'\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; '
            f'lastKnownFileType = {file_type}; '
            f'name = "{filename}"; '
            f'path = "{filepath}"; '
            f'sourceTree = "<group>"; }};\n'
        )

        # PBXBuildFile
        build_phase = get_build_phase(filepath)
        if build_phase:
            build_file_section.append(
                f'\t\t{build_file_uuid} /* {filename} in {build_phase.title()} */ = '
                f'{{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};\n'
            )

            if build_phase == 'sources':
                source_build_phase_files.append(build_file_uuid)
            elif build_phase == 'resources':
                resource_build_phase_files.append(build_file_uuid)

    # UUIDs for build phases
    sources_build_phase_uuid = generate_uuid()
    resources_build_phase_uuid = generate_uuid()
    frameworks_build_phase_uuid = generate_uuid()

    # Target UUID
    target_uuid = generate_uuid()

    # Configuration UUIDs
    debug_config_uuid = generate_uuid()
    release_config_uuid = generate_uuid()
    config_list_target_uuid = generate_uuid()
    config_list_project_uuid = generate_uuid()

    # Product reference
    product_uuid = generate_uuid()
    products_group_uuid = generate_uuid()

    # Build project file
    pbx_content = f'''// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{''.join(build_file_section)}\t\t/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{''.join(file_ref_section)}\t\t{product_uuid} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "{PROJECT_NAME}.app"; sourceTree = BUILT_PRODUCTS_DIR; }};
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
\t\t{main_group_uuid} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */," for f in INCLUDE_FILES if f in file_refs)}
\t\t\t\t{products_group_uuid} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{products_group_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{product_uuid} /* {PROJECT_NAME}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_uuid} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {config_list_target_uuid} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_build_phase_uuid} /* Sources */,
\t\t\t\t{frameworks_build_phase_uuid} /* Frameworks */,
\t\t\t\t{resources_build_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {PROJECT_NAME};
\t\t\tproductName = {PROJECT_NAME};
\t\t\tproductReference = {product_uuid} /* {PROJECT_NAME}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{generate_uuid()} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1530;
\t\t\t\tLastUpgradeCheck = 1530;
\t\t\t}};
\t\t\tbuildConfigurationList = {config_list_project_uuid} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uuid} /* {PROJECT_NAME} */;
\t\t\tproductRefGroup = {products_group_uuid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uuid} /* {PROJECT_NAME} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{resources_build_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(f"\t\t\t\t{uuid} /* {[f for f, u in build_files.items() if u == uuid][0]} */," for uuid in resource_build_phase_files)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_build_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(f"\t\t\t\t{uuid} /* {[f for f, u in build_files.items() if u == uuid][0]} */," for uuid in source_build_phase_files)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{generate_uuid()} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = BuilderOS.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{generate_uuid()} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = BuilderOS.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{config_list_project_uuid} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_uuid} /* Debug */,
\t\t\t\t{release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{config_list_target_uuid} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{generate_uuid()} /* Debug */,
\t\t\t\t{generate_uuid()} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {generate_uuid()} /* Project object */;
}}
'''

    return pbx_content

def main():
    """Create the Xcode project."""
    os.chdir(PROJECT_DIR)

    # Remove old project if exists
    project_path = f"{PROJECT_NAME}.xcodeproj"
    if os.path.exists(project_path):
        print(f"🗑️  Removing old project: {project_path}")
        os.system(f"rm -rf {project_path}")

    # Create project directory structure
    os.makedirs(f"{project_path}/project.xcworkspace/xcshareddata", exist_ok=True)
    os.makedirs(f"{project_path}/xcshareddata/xcschemes", exist_ok=True)

    # Generate and write project.pbxproj
    print(f"📝 Generating project file...")
    pbx_content = create_pbx_project()

    with open(f"{project_path}/project.pbxproj", 'w') as f:
        f.write(pbx_content)

    # Create workspace settings
    workspace_settings = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>BuildSystemType</key>
\t<string>Original</string>
\t<key>IDEWorkspaceSharedSettings_AutocreateContextsIfNeeded</key>
\t<false/>
</dict>
</plist>'''

    with open(f"{project_path}/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings", 'w') as f:
        f.write(workspace_settings)

    # Create scheme
    scheme_uuid = generate_uuid()
    scheme_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1530"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{scheme_uuid}"
               BuildableName = "{PROJECT_NAME}.app"
               BlueprintName = "{PROJECT_NAME}"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{scheme_uuid}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
</Scheme>'''

    with open(f"{project_path}/xcshareddata/xcschemes/{PROJECT_NAME}.xcscheme", 'w') as f:
        f.write(scheme_content)

    print(f"\n✅ Linked Xcode project created: {project_path}")
    print(f"📁 Included files:")
    for filepath in INCLUDE_FILES:
        if os.path.exists(os.path.join(PROJECT_DIR, filepath)):
            print(f"   ✅ {filepath}")
        else:
            print(f"   ⚠️  {filepath} (missing)")

    print(f"\n🚀 Open with: open '{project_path}'")
    print(f"🔗 All source files are linked (not copied)")

    return 0

if __name__ == "__main__":
    sys.exit(main())
