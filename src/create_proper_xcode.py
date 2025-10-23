#!/usr/bin/env python3
"""
Create a proper Xcode project for BuilderOS iOS app
Includes all Swift files from the correct locations
"""

import os
import uuid
import glob

def generate_uuid():
    """Generate a unique 24-character hex ID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

def find_swift_files(base_dir):
    """Find all Swift files we need to include"""
    files = {
        'app': [],          # Main app files
        'views': [],        # View files
        'services': [],     # Service files
        'models': [],       # Model files
        'utilities': [],    # Utility files
        'chat': []          # Chat feature files
    }

    # Main app entry point
    app_file = os.path.join(base_dir, 'BuilderOSApp.swift')
    if os.path.exists(app_file):
        files['app'].append(('BuilderOSApp.swift', app_file))

    # Views (exclude backup versions)
    views_dir = os.path.join(base_dir, 'Views')
    if os.path.exists(views_dir):
        for swift_file in glob.glob(os.path.join(views_dir, '*.swift')):
            # Skip backup files
            if '_backup' in swift_file or '_Full' in swift_file:
                continue
            name = os.path.basename(swift_file)
            files['views'].append((name, swift_file))

    # Services
    services_dir = os.path.join(base_dir, 'Services')
    if os.path.exists(services_dir):
        for swift_file in glob.glob(os.path.join(services_dir, '*.swift')):
            name = os.path.basename(swift_file)
            files['services'].append((name, swift_file))

    # Voice services (TTS and Voice recognition)
    voice_services_dir = os.path.join(base_dir, 'BuilderSystemMobile/Services/Voice')
    if os.path.exists(voice_services_dir):
        for swift_file in glob.glob(os.path.join(voice_services_dir, '*.swift')):
            name = 'Voice/' + os.path.basename(swift_file)
            files['services'].append((name, swift_file))

    # SSH services (exclude backup/full versions)
    ssh_services_dir = os.path.join(base_dir, 'BuilderSystemMobile/Services/SSH')
    if os.path.exists(ssh_services_dir):
        for swift_file in glob.glob(os.path.join(ssh_services_dir, '*.swift')):
            # Skip backup files
            if '_Full' in swift_file or '_backup' in swift_file:
                continue
            name = 'SSH/' + os.path.basename(swift_file)
            files['services'].append((name, swift_file))

    # Common/Theme
    theme_file = os.path.join(base_dir, 'BuilderSystemMobile/Common/Theme.swift')
    if os.path.exists(theme_file):
        files['utilities'].append(('Theme.swift', theme_file))

    # Models
    models_dir = os.path.join(base_dir, 'Models')
    if os.path.exists(models_dir):
        for swift_file in glob.glob(os.path.join(models_dir, '*.swift')):
            name = os.path.basename(swift_file)
            files['models'].append((name, swift_file))

    # Utilities
    utilities_dir = os.path.join(base_dir, 'Utilities')
    if os.path.exists(utilities_dir):
        for swift_file in glob.glob(os.path.join(utilities_dir, '*.swift')):
            name = os.path.basename(swift_file)
            files['utilities'].append((name, swift_file))

    # Chat features
    chat_dir = os.path.join(base_dir, 'BuilderSystemMobile/Features/Chat')
    if os.path.exists(chat_dir):
        # Models
        chat_models = os.path.join(chat_dir, 'Models')
        if os.path.exists(chat_models):
            for swift_file in glob.glob(os.path.join(chat_models, '*.swift')):
                name = 'Chat/' + os.path.basename(swift_file)
                files['chat'].append((name, swift_file))

        # ViewModels
        chat_vms = os.path.join(chat_dir, 'ViewModels')
        if os.path.exists(chat_vms):
            for swift_file in glob.glob(os.path.join(chat_vms, '*.swift')):
                name = 'Chat/' + os.path.basename(swift_file)
                files['chat'].append((name, swift_file))

        # Views
        chat_views = os.path.join(chat_dir, 'Views')
        if os.path.exists(chat_views):
            for swift_file in glob.glob(os.path.join(chat_views, '*.swift')):
                name = 'Chat/' + os.path.basename(swift_file)
                files['chat'].append((name, swift_file))

    return files

def create_pbxproj(base_dir, files_dict):
    """Generate Xcode project.pbxproj content"""

    # Generate UUIDs for all files
    file_refs = {}
    build_files = {}

    all_files = []
    for category, file_list in files_dict.items():
        for name, path in file_list:
            rel_path = os.path.relpath(path, base_dir)
            file_id = generate_uuid()
            build_id = generate_uuid()
            file_refs[name] = {
                'id': file_id,
                'name': name,
                'path': rel_path,
                'build_id': build_id
            }
            all_files.append(name)

    # Generate fixed UUIDs for groups and targets
    app_group_id = generate_uuid()
    products_group_id = generate_uuid()
    main_group_id = generate_uuid()
    views_group_id = generate_uuid()
    services_group_id = generate_uuid()
    models_group_id = generate_uuid()
    utilities_group_id = generate_uuid()
    chat_group_id = generate_uuid()

    target_id = generate_uuid()
    project_id = generate_uuid()
    sources_phase_id = generate_uuid()
    frameworks_phase_id = generate_uuid()
    resources_phase_id = generate_uuid()

    product_ref_id = generate_uuid()
    debug_config_id = generate_uuid()
    release_config_id = generate_uuid()
    project_debug_id = generate_uuid()
    project_release_id = generate_uuid()
    target_config_list_id = generate_uuid()
    project_config_list_id = generate_uuid()

    # Start building the pbxproj content
    content = """// !$*UTF8*$!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

/* Begin PBXBuildFile section */
"""

    # Add build file entries
    for name in sorted(all_files):
        ref = file_refs[name]
        content += f"\t\t{ref['build_id']} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref['id']} /* {name} */; }};\n"

    content += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

    # Add file reference entries
    content += f"\t\t{product_ref_id} /* BuilderOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BuilderOS.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"

    for name in sorted(all_files):
        ref = file_refs[name]
        content += f"\t\t{ref['id']} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {name}; path = {ref['path']}; sourceTree = \"<group>\"; }};\n"

    content += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
"""

    content += f"""\t\t{frameworks_phase_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""

    # Main group
    content += f"""\t\t{main_group_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_group_id} /* BuilderOS */,
\t\t\t\t{products_group_id} /* Products */,
\t\t\t);
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    # Products group
    content += f"""\t\t{products_group_id} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{product_ref_id} /* BuilderOS.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    # App group
    content += f"""\t\t{app_group_id} /* BuilderOS */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""

    # Add app files
    for name, _ in files_dict['app']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"

    # Add group references
    content += f"\t\t\t\t{views_group_id} /* Views */,\n"
    content += f"\t\t\t\t{services_group_id} /* Services */,\n"
    content += f"\t\t\t\t{models_group_id} /* Models */,\n"
    content += f"\t\t\t\t{utilities_group_id} /* Utilities */,\n"
    content += f"\t\t\t\t{chat_group_id} /* Chat */,\n"

    content += """\t\t\t);
\t\t\tname = BuilderOS;
\t\t\tsourceTree = \"<group>\";
\t\t};
"""

    # Views group
    content += f"""\t\t{views_group_id} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, _ in files_dict['views']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"
    content += """\t\t\t);
\t\t\tname = Views;
\t\t\tsourceTree = \"<group>\";
\t\t};
"""

    # Services group
    content += f"""\t\t{services_group_id} /* Services */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, _ in files_dict['services']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"
    content += """\t\t\t);
\t\t\tname = Services;
\t\t\tsourceTree = \"<group>\";
\t\t};
"""

    # Models group
    content += f"""\t\t{models_group_id} /* Models */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, _ in files_dict['models']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"
    content += """\t\t\t);
\t\t\tname = Models;
\t\t\tsourceTree = \"<group>\";
\t\t};
"""

    # Utilities group
    content += f"""\t\t{utilities_group_id} /* Utilities */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, _ in files_dict['utilities']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"
    content += """\t\t\t);
\t\t\tname = Utilities;
\t\t\tsourceTree = \"<group>\";
\t\t};
"""

    # Chat group
    content += f"""\t\t{chat_group_id} /* Chat */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""
    for name, _ in files_dict['chat']:
        content += f"\t\t\t\t{file_refs[name]['id']} /* {name} */,\n"
    content += """\t\t\t);
\t\t\tname = Chat;
\t\t\tsourceTree = \"<group>\";
\t\t};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
"""

    content += f"""\t\t{target_id} /* BuilderOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_config_list_id} /* Build configuration list for PBXNativeTarget \"BuilderOS\" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_id} /* Sources */,
\t\t\t\t{frameworks_phase_id} /* Frameworks */,
\t\t\t\t{resources_phase_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = BuilderOS;
\t\t\tproductName = BuilderOS;
\t\t\tproductReference = {product_ref_id} /* BuilderOS.app */;
\t\t\tproductType = \"com.apple.product-type.application\";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
"""

    content += f"""\t\t{project_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_id} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {project_config_list_id} /* Build configuration list for PBXProject \"BuilderOS\" */;
\t\t\tcompatibilityVersion = \"Xcode 14.0\";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_id};
\t\t\tproductRefGroup = {products_group_id} /* Products */;
\t\t\tprojectDirPath = \"\";
\t\t\tprojectRoot = \"\";
\t\t\ttargets = (
\t\t\t\t{target_id} /* BuilderOS */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
"""

    content += f"""\t\t{resources_phase_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
"""

    content += f"""\t\t{sources_phase_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
"""

    for name in sorted(all_files):
        ref = file_refs[name]
        content += f"\t\t\t\t{ref['build_id']} /* {name} in Sources */,\n"

    content += """\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
"""

    # Project debug configuration
    content += f"""\t\t{project_debug_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
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
\t\t\t\t\t\"DEBUG=1\",
\t\t\t\t\t\"$(inherited)\",
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
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
"""

    # Project release configuration
    content += f"""\t\t{project_release_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
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
\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";
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
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-O\";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
"""

    # Target debug configuration
    content += f"""\t\t{debug_config_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
"""

    # Target release configuration
    content += f"""\t\t{release_config_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
"""

    # Configuration lists
    content += f"""\t\t{project_config_list_id} /* Build configuration list for PBXProject \"BuilderOS\" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{project_debug_id} /* Debug */,
\t\t\t\t{project_release_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{target_config_list_id} /* Build configuration list for PBXNativeTarget \"BuilderOS\" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_id} /* Debug */,
\t\t\t\t{release_config_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_id} /* Project object */;
}}
"""

    return content

def main():
    base_dir = '/Users/Ty/BuilderOS/capsules/builder-system-mobile/src'

    print("Finding Swift files...")
    files = find_swift_files(base_dir)

    total_files = sum(len(f) for f in files.values())
    print(f"Found {total_files} Swift files:")
    for category, file_list in files.items():
        if file_list:
            print(f"  {category}: {len(file_list)} files")
            for name, _ in file_list:
                print(f"    - {name}")

    print("\nGenerating Xcode project...")
    pbxproj_content = create_pbxproj(base_dir, files)

    # Create project directory structure
    project_dir = os.path.join(base_dir, 'BuilderOS.xcodeproj')
    os.makedirs(project_dir, exist_ok=True)

    # Write project.pbxproj
    pbxproj_path = os.path.join(project_dir, 'project.pbxproj')
    with open(pbxproj_path, 'w') as f:
        f.write(pbxproj_content)

    # Create workspace
    workspace_dir = os.path.join(project_dir, 'project.xcworkspace')
    os.makedirs(workspace_dir, exist_ok=True)

    workspace_content = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""

    workspace_path = os.path.join(workspace_dir, 'contents.xcworkspacedata')
    with open(workspace_path, 'w') as f:
        f.write(workspace_content)

    print(f"\n✅ Xcode project created successfully!")
    print(f"📁 Location: {project_dir}")
    print(f"📝 Total files: {total_files}")
    print(f"\n🚀 Open with: open '{project_dir}'")

if __name__ == '__main__':
    main()
