#!/usr/bin/env python3
"""
Add Inject Swift package to BuilderOS Xcode project using xcodeproj library.
"""

import subprocess
import sys
import os

def install_xcodeproj_lib():
    """Install mod-pbxproj if not available."""
    try:
        import pbxproj
        return True
    except ImportError:
        print("Installing mod-pbxproj library...")
        result = subprocess.run(
            [sys.executable, "-m", "pip", "install", "mod-pbxproj"],
            capture_output=True
        )
        if result.returncode == 0:
            print("✓ mod-pbxproj installed successfully")
            return True
        else:
            print(f"✗ Failed to install mod-pbxproj: {result.stderr.decode()}")
            return False

def add_swift_package(project_path, package_url, version="1.0.0"):
    """Add Swift package dependency using pbxproj library."""
    try:
        from pbxproj import XcodeProject
    except ImportError:
        print("Error: pbxproj library not available")
        return False

    print(f"\nOpening project: {project_path}")
    project = XcodeProject.load(project_path + '/project.pbxproj')

    print(f"Adding package: {package_url}")

    # Add package reference
    package_ref = project.add_package(
        url=package_url,
        requirement={
            'kind': 'upToNextMajorVersion',
            'minimumVersion': version
        }
    )

    if package_ref:
        print(f"✓ Package reference added: {package_ref}")

        # Add package product to target
        targets = project.get_targets()
        if targets:
            target = targets[0]  # BuilderOS target
            print(f"Adding Inject product to target: {target.name}")

            # Add the Inject product dependency
            product = project.add_package_product(
                package=package_ref,
                product_name='Inject',
                target=target
            )

            if product:
                print(f"✓ Package product added to target")
            else:
                print("✗ Failed to add package product")
                return False
        else:
            print("✗ No targets found")
            return False

        # Save the project
        print("\nSaving project...")
        project.save()
        print("✓ Project saved successfully")
        return True
    else:
        print("✗ Failed to add package reference")
        return False

if __name__ == "__main__":
    project_path = "/Users/Ty/BuilderOS/capsules/builderos-mobile/src/BuilderOS.xcodeproj"
    package_url = "https://github.com/krzysztofzablocki/Inject"

    print("BuilderOS - Add Inject Package")
    print("="*60)

    if not os.path.exists(project_path):
        print(f"✗ Error: Project not found at {project_path}")
        sys.exit(1)

    # Install library if needed
    if not install_xcodeproj_lib():
        print("\n✗ Cannot proceed without mod-pbxproj library")
        sys.exit(1)

    # Add the package
    success = add_swift_package(project_path, package_url)

    if success:
        print("\n" + "="*60)
        print("✓ SUCCESS: Inject package added to project!")
        print("="*60)
        print("\nNext steps:")
        print("1. Open Xcode: open BuilderOS.xcodeproj")
        print("2. Build project (Cmd+B) to verify")
        print("3. Check that Inject package appears in Project Navigator")
        sys.exit(0)
    else:
        print("\n✗ Failed to add package")
        sys.exit(1)
