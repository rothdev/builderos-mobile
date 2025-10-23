#!/usr/bin/env python3
"""Create minimal Xcode project with just one app file"""

import os
import uuid

def generate_uuid():
    return uuid.uuid4().hex[:24].upper()

def main():
    base_dir = '/Users/Ty/BuilderOS/capsules/builder-system-mobile/src'
    app_file = os.path.join(base_dir, 'MinimalApp.swift')
    
    # UUIDs
    file_ref_id = generate_uuid()
    build_file_id = generate_uuid()
    app_group_id = generate_uuid()
    products_group_id = generate_uuid()
    main_group_id = generate_uuid()
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
    
    content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
\t\t{build_file_id} /* MinimalApp.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* MinimalApp.swift */; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\t\t{product_ref_id} /* BuilderOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BuilderOS.app; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{file_ref_id} /* MinimalApp.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = MinimalApp.swift; path = MinimalApp.swift; sourceTree = \"<group>\"; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{frameworks_phase_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{main_group_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_group_id} /* BuilderOS */,
\t\t\t\t{products_group_id} /* Products */,
\t\t\t);
\t\t\tsourceTree = \"<group>\";
\t\t}};
\t\t{products_group_id} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{product_ref_id} /* BuilderOS.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = \"<group>\";
\t\t}};
\t\t{app_group_id} /* BuilderOS */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{file_ref_id} /* MinimalApp.swift */,
\t\t\t);
\t\t\tname = BuilderOS;
\t\t\tsourceTree = \"<group>\";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_id} /* BuilderOS */ = {{
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
\t\t{project_id} /* Project object */ = {{
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
\t\t{resources_phase_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_phase_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{build_file_id} /* MinimalApp.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{project_debug_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{project_release_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{debug_config_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_config_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.builderos.mobile;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{project_config_list_id} /* Build configuration list for PBXProject \"BuilderOS\" */ = {{
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
    
    project_dir = os.path.join(base_dir, 'BuilderOS.xcodeproj')
    os.makedirs(project_dir, exist_ok=True)
    
    # Write project.pbxproj
    pbxproj_path = os.path.join(project_dir, 'project.pbxproj')
    with open(pbxproj_path, 'w') as f:
        f.write(content)
    
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
    
    print(f"\n✅ Minimal Xcode project created!")
    print(f"📁 Location: {project_dir}")
    print(f"📝 Single file: MinimalApp.swift")
    print(f"\n🚀 Build with: xcodebuild -project BuilderOS.xcodeproj -scheme BuilderOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build")

if __name__ == '__main__':
    main()
