#!/usr/bin/env python3
"""
Create a proper Xcode project for BuilderOS iOS app with all Swift source files.
This script creates a linked Xcode project (files referenced, not copied).
"""

import os
import sys
import uuid
import subprocess
from pathlib import Path

def generate_uuid():
    """Generate a 24-character hex ID for Xcode."""
    return uuid.uuid4().hex[:24].upper()

def find_swift_files(base_dir):
    """Find all Swift files excluding certain directories."""
    swift_files = []
    exclude_dirs = {'.build', '.swiftpm', 'BuilderOS.xcodeproj', 'ios'}

    for root, dirs, files in os.walk(base_dir):
        # Remove excluded directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]

        for file in files:
            if file.endswith('.swift'):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, base_dir)
                swift_files.append(rel_path)

    return sorted(swift_files)

def create_group_structure(files):
    """Organize files into logical groups."""
    groups = {
        'App': [],
        'Models': [],
        'Views': [],
        'Services': [],
        'Utilities': [],
        'Features': [],
        'Supporting Files': []
    }

    for file in files:
        if 'App.swift' in file or file == 'BuilderOSApp.swift':
            groups['App'].append(file)
        elif file.startswith('Models/'):
            groups['Models'].append(file)
        elif file.startswith('Views/'):
            groups['Views'].append(file)
        elif file.startswith('Services/'):
            groups['Services'].append(file)
        elif file.startswith('Utilities/'):
            groups['Utilities'].append(file)
        elif 'Features/' in file:
            groups['Features'].append(file)
        else:
            groups['Supporting Files'].append(file)

    # Remove empty groups
    return {k: v for k, v in groups.items() if v}

def create_pbxproj(base_dir, swift_files):
    """Create the project.pbxproj file content."""

    # Generate UUIDs for all files and build phases
    file_refs = {f: generate_uuid() for f in swift_files}
    build_files = {f: generate_uuid() for f in swift_files}

    # Static UUIDs for main project structure
    project_uuid = generate_uuid()
    target_uuid = generate_uuid()
    sources_phase_uuid = generate_uuid()
    frameworks_phase_uuid = generate_uuid()
    resources_phase_uuid = generate_uuid()
    main_group_uuid = generate_uuid()
    products_group_uuid = generate_uuid()
    app_product_uuid = generate_uuid()
    project_config_list_uuid = generate_uuid()
    target_config_list_uuid = generate_uuid()
    debug_project_config_uuid = generate_uuid()
    release_project_config_uuid = generate_uuid()
    debug_target_config_uuid = generate_uuid()
    release_target_config_uuid = generate_uuid()

    # Group UUIDs
    group_uuids = {
        'App': generate_uuid(),
        'Models': generate_uuid(),
        'Views': generate_uuid(),
        'Services': generate_uuid(),
        'Utilities': generate_uuid(),
        'Features': generate_uuid(),
        'Supporting Files': generate_uuid()
    }

    groups = create_group_structure(swift_files)

    # Build PBXBuildFile section
    build_file_section = []
    for file, build_uuid in build_files.items():
        file_ref = file_refs[file]
        filename = os.path.basename(file)
        build_file_section.append(f"\t\t{build_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {filename} */; }};")

    # Build PBXFileReference section
    file_ref_section = []
    file_ref_section.append(f"\t\t{app_product_uuid} /* BuilderOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BuilderOS.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    for file, file_uuid in file_refs.items():
        filename = os.path.basename(file)
        file_ref_section.append(f"\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {filename}; path = {file}; sourceTree = \"<group>\"; }};")

    # Build PBXGroup sections
    group_sections = []

    # Main group
    main_group_children = []
    for group_name in groups.keys():
        if group_name in group_uuids:
            main_group_children.append(f"\t\t\t\t{group_uuids[group_name]} /* {group_name} */,")
    main_group_children.append(f"\t\t\t\t{products_group_uuid} /* Products */,")

    main_group_section = f"""
\t\t{main_group_uuid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(main_group_children)}
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};"""
    group_sections.append(main_group_section)

    # Products group
    products_group = f"""
\t\t{products_group_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_uuid} /* BuilderOS.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    group_sections.append(products_group)

    # Individual groups for each category
    for group_name, files in groups.items():
        if not files or group_name not in group_uuids:
            continue

        children = []
        for file in files:
            file_uuid = file_refs[file]
            filename = os.path.basename(file)
            children.append(f"\t\t\t\t{file_uuid} /* {filename} */,")

        group_section = f"""
\t\t{group_uuids[group_name]} /* {group_name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(children)}
\t\t\t);
\t\t\tname = {group_name};
\t\t\tsourceTree = "<group>";
\t\t}};"""
        group_sections.append(group_section)

    # Build Sources phase
    source_files_list = []
    for file, build_uuid in build_files.items():
        filename = os.path.basename(file)
        source_files_list.append(f"\t\t\t\t{build_uuid} /* {filename} in Sources */,")

    # Create the full project.pbxproj content
    pbxproj_content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_file_section)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_ref_section)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{frameworks_phase_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(group_sections)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_uuid} /* BuilderOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_config_list_uuid} /* Build configuration list for PBXNativeTarget "BuilderOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_uuid} /* Sources */,
\t\t\t\t{frameworks_phase_uuid} /* Frameworks */,
\t\t\t\t{resources_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = BuilderOS;
\t\t\tproductName = BuilderOS;
\t\t\tproductReference = {app_product_uuid} /* BuilderOS.app */;
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
\t\t\tbuildConfigurationList = {project_config_list_uuid} /* Build configuration list for PBXProject "BuilderOS" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uuid};
\t\t\tproductRefGroup = {products_group_uuid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uuid} /* BuilderOS */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{resources_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(source_files_list)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{debug_project_config_uuid} /* Debug */ = {{
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
\t\t\t\t\t"$$(inherited)",
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
\t\t{release_project_config_uuid} /* Release */ = {{
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
\t\t{debug_target_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "BuilderOS/Preview\\\\ Content";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = "$$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_target_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "BuilderOS/Preview\\\\ Content";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = "$$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{project_config_list_uuid} /* Build configuration list for PBXProject "BuilderOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_project_config_uuid} /* Debug */,
\t\t\t\t{release_project_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "BuilderOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_target_config_uuid} /* Debug */,
\t\t\t\t{release_target_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uuid} /* Project object */;
}}
"""

    return pbxproj_content

def main():
    base_dir = Path('/Users/Ty/BuilderOS/capsules/builder-system-mobile/src')

    # Find all Swift files
    print("🔍 Finding Swift source files...")
    swift_files = find_swift_files(base_dir)

    if not swift_files:
        print("❌ No Swift files found!")
        return 1

    print(f"✅ Found {len(swift_files)} Swift files")
    for f in swift_files:
        print(f"   - {f}")

    # Remove old project if exists
    project_dir = base_dir / 'BuilderOS.xcodeproj'
    if project_dir.exists():
        print(f"\n🗑️  Removing old project: {project_dir}")
        subprocess.run(['rm', '-rf', str(project_dir)])

    # Create project directory
    print(f"\n📁 Creating project directory: {project_dir}")
    project_dir.mkdir(exist_ok=True)

    # Create project.pbxproj
    print("📝 Generating project.pbxproj...")
    pbxproj_content = create_pbxproj(base_dir, swift_files)

    pbxproj_path = project_dir / 'project.pbxproj'
    with open(pbxproj_path, 'w') as f:
        f.write(pbxproj_content)

    print(f"✅ Created: {pbxproj_path}")

    # Create xcshareddata directory for schemes
    xcshareddata_dir = project_dir / 'xcshareddata' / 'xcschemes'
    xcshareddata_dir.mkdir(parents=True, exist_ok=True)

    # Create BuilderOS.xcscheme
    scheme_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
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
               BlueprintIdentifier = "BuilderOS"
               BuildableName = "BuilderOS.app"
               BlueprintName = "BuilderOS"
               ReferencedContainer = "container:BuilderOS.xcodeproj">
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
            BlueprintIdentifier = "BuilderOS"
            BuildableName = "BuilderOS.app"
            BlueprintName = "BuilderOS"
            ReferencedContainer = "container:BuilderOS.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>"""

    scheme_path = xcshareddata_dir / 'BuilderOS.xcscheme'
    with open(scheme_path, 'w') as f:
        f.write(scheme_content)

    print(f"✅ Created scheme: {scheme_path}")

    print("\n✅ SUCCESS: Fresh Xcode project created!")
    print(f"📁 Location: {project_dir}")
    print(f"🔗 All {len(swift_files)} Swift files are LINKED (not copied)")
    print(f"\n🚀 Open in Xcode: open '{project_dir}'")
    print(f"🛠️  Build: cd '{base_dir}' && xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS build")

    return 0

if __name__ == '__main__':
    sys.exit(main())
